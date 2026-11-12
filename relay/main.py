"""
Text-to-speech relay for the Muse charm, on Google Cloud Run.

The charm POSTs a reply's text here and gets back an MP3 made by Google Cloud
Text-to-Speech. Two things keep spending capped:

- There is no Google API key anywhere: this service calls Text-to-Speech as its
  own Cloud Run identity, so nothing on the charm can be used to spend money
  directly.
- Every request is counted against a daily character limit, stored in
  Firestore so it survives restarts. Past the limit the relay answers 429 and
  the charm just shows the reply as text.

Env vars (set at deploy time, see README.md):
  RELAY_TOKEN       what the charm sends as "Authorization: Bearer <token>"
  DAILY_CHAR_LIMIT  characters per day, all requests together (default 30000)
  VOICE             Google voice name (default en-US-Neural2-F)
"""

import datetime
import hmac
import os
from zoneinfo import ZoneInfo

from flask import Flask, Response, request
from google.cloud import firestore, texttospeech

TOKEN = os.environ["RELAY_TOKEN"]
DAILY_LIMIT = int(os.environ.get("DAILY_CHAR_LIMIT", "30000"))
VOICE = os.environ.get("VOICE", "en-US-Neural2-F")
MAX_CHARS = 1500                     # one reply; Google's own limit is 5000 bytes
DAY_ZONE = ZoneInfo("America/Toronto")

app = Flask(__name__)
db = firestore.Client()
tts = texttospeech.TextToSpeechClient()


@firestore.transactional
def reserve(tx, ref, n):
    """Adds n characters to today's count unless that would pass the limit."""
    snap = ref.get(transaction=tx)
    used = (snap.to_dict() or {}).get("chars", 0) if snap.exists else 0
    if used + n > DAILY_LIMIT:
        return False, used
    tx.set(ref, {"chars": used + n}, merge=True)
    return True, used + n


@app.post("/tts")
def speak():
    if not hmac.compare_digest(request.headers.get("Authorization", ""), f"Bearer {TOKEN}"):
        return Response("unauthorized\n", 401)
    text = request.get_data(as_text=True).strip()[:MAX_CHARS]
    if not text:
        return Response("no text\n", 400)

    day = datetime.datetime.now(DAY_ZONE).date().isoformat()
    ok, used = reserve(db.transaction(), db.collection("tts_usage").document(day), len(text))
    if not ok:
        return Response(f"daily limit reached ({used}/{DAILY_LIMIT} characters)\n", 429)

    audio = tts.synthesize_speech(
        input=texttospeech.SynthesisInput(text=text),
        voice=texttospeech.VoiceSelectionParams(language_code=VOICE[:5], name=VOICE),
        audio_config=texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.MP3, sample_rate_hertz=24000),
    ).audio_content
    return Response(audio, mimetype="audio/mpeg")


@app.get("/")
def health():
    return "ok\n"
