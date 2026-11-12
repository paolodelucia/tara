# Text-to-speech relay (Google Cloud Run)

Muse only sends gadgets text. The charm POSTs each finished reply here and gets
back an MP3 from Google Cloud Text-to-Speech, which it plays.

```
charm --POST /tts (text, Authorization: Bearer <token>)--> relay --> Google TTS
charm <--------------------------- audio/mpeg -------------------------'
```

## Spending is capped by design

The rule for this project: **never more than $5 a day, even if the charm or its
token leaks.**

- **No Google API key anywhere.** The relay calls Text-to-Speech as its own
  Cloud Run identity, so nothing on the charm can spend money directly.
- **A daily character limit** (default 30,000, about $0.50 a day at Neural2
  prices, and inside the free tier most months), counted in Firestore so it
  survives restarts. Past it, the relay answers 429 and the charm shows text.
- **At most 1 instance**, so a flood of requests can't scale up the bill.
- A budget alert on the billing account as a last warning.

## Deploy your own

With the [gcloud CLI](https://cloud.google.com/sdk/docs/install), in a project
with billing on:

1. Turn on the APIs: Cloud Run, Cloud Build, Text-to-Speech, Firestore. Create a
   Firestore database (Native mode) in the same region.
2. Make a long random token (for example `python -c "import secrets; print(secrets.token_urlsafe(32))"`).
3. From this folder:
   ```
   gcloud run deploy tts-relay --source . --region YOUR_REGION --project YOUR_PROJECT --allow-unauthenticated --max-instances 1 --set-env-vars RELAY_TOKEN=YOUR_TOKEN
   ```
   `--allow-unauthenticated` only means Google doesn't check a login; the relay
   checks the bearer token itself.
4. If the relay logs a Firestore permission error, give the service's identity
   the "Cloud Datastore User" role.
5. Put the URL (ending in `/tts`) and the token in the charm's
   `secrets.local` (see [charm/README.md](../charm/README.md)), then rebuild.

Optional env vars: `DAILY_CHAR_LIMIT` (default 30000) and `VOICE` (default
`en-US-Neural2-F`). Change one later with
`gcloud run services update tts-relay --update-env-vars DAILY_CHAR_LIMIT=20000`.
