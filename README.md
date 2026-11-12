# Tara

A voice assistant you wear on a lanyard: a 1.8" AMOLED ESP32-S3 board in a
3D-printed case with its own battery. Hold a button, speak, and the answer shows
on screen and is spoken out loud. At home it snaps onto a magnetic wall dock to
charge.

<!-- Photos: the charm on the lanyard, docked on the wall, inside the case. -->

**Now:** the board runs as a **Muse charm**: Meta's open-source
[Muse gadget SDK](https://github.com/facebookincubator/muse-gadget-sdk) firmware,
talking to my Muse agent, Tara, with a few changes of ours (spoken replies,
campus Wi-Fi, a battery charge limit). **Before that** it was Tara v0, a
Claude-based voice loop through a server on my laptop; that code is still here
and still works.

```
Charm (ESP32-S3) --voice--> Muse --text--> Charm --text--> TTS relay (Cloud Run) --MP3--> Charm speaker
```

## What's in here

| Path | What |
|---|---|
| [`case/`](case/) | The 3D-printed back cover (battery, magnets, keyring tab, speaker grille) and the magnetic wall dock: OpenSCAD source, STLs, print settings |
| [`charm/`](charm/) | How to build and flash the Muse charm firmware, and the tools for it. The firmware changes are in the fork [paolodelucia/muse-gadget-sdk](https://github.com/paolodelucia/muse-gadget-sdk) (branch `charm`) |
| [`relay/`](relay/) | The text-to-speech relay that gives replies a voice, with hard spending caps |
| [`docs/`](docs/) | [Parts list](docs/parts-list.md), [build guide](docs/build-guide.md), [battery notes](docs/battery.md), the [room node plan](docs/room-node-plan.md), and [Spells](docs/spells.md) |
| `firmware/tara_v0/`, `server/` | Tara v0: Arduino sketch plus a Python server (Whisper, Claude, Piper) |
| `firmware/spell_recorder/`, `spells/` | Spells (paused): teach the board a gesture from one example, then cast it |
| `experiments/` | First ESP32 sketches: blink and a Bluetooth "ghost keyboard" |

## Hardware

- [Waveshare ESP32-S3-Touch-AMOLED-1.8](https://www.waveshare.com/esp32-s3-touch-amoled-1.8.htm),
  **V2** (CO5300 display, CST820 touch, ES8311 audio codec, mic and speaker, AXP2101
  power chip)
- 3.7 V 300 mAh LiPo (32 × 20 × 6 mm), magnets, M2 × 10 screws: see the
  [parts list](docs/parts-list.md)

## Security

Anyone holding the charm can talk to it, so the agent behind it only gets
**read and draft** access: it can read mail and write drafts, but has no tool
that sends, spends or deletes. Cloud spending is capped at the source (see
[relay/](relay/)). No secrets live in this repo: Wi-Fi passwords, tokens and
the relay's URL stay in git-ignored files.

## Tara v0 (Claude, the earlier version)

```
Tara (ESP32-S3)    --raw audio-->  server.py  -->  Whisper  -->  Claude  -->  Piper
Tara               <--text + speech----------------------------------------'
```

The device records, plays audio and shows text; everything smart runs on the
server. Press, talk, and the answer comes back in about 2 seconds.

### Server (Windows)

Use **Python 3.12**. Some dependencies don't support 3.14 yet.

```bat
cd server
py -3.12 -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python -m piper.download_voices en_US-lessac-medium
setx ANTHROPIC_API_KEY "sk-ant-..."
```

Create the API key **inside a workspace** (Console > Settings > Workspaces). An
organization-level key fails with "not scoped to a workspace". Alternatively, set
`TARA_WORKSPACE` to the workspace ID.

Open a **new** terminal (so it picks up the key), activate the venv, and run:

```bat
set TARA_MODEL=claude-sonnet-5-5
python server.py
```

It prints the address to put in the firmware. Test without the board:
`python test_talk.py "What is the capital of Italy?"`, which saves `reply.wav`.

### Firmware

1. Install Waveshare's Arduino libraries from their repo (`examples/arduino-v2/libraries`).
2. In `firmware/tara_v0/`, copy `secrets.example.h` to `secrets.h` and fill in your
   networks: one `{ ssid, password, server }` line each. Tara joins the strongest one
   it knows. `secrets.h` is git-ignored, so your passwords stay out of the repo.
   The board needs 2.4 GHz Wi-Fi on the same network as the server.
3. Tools: **ESP32S3 Dev Module**, USB CDC On Boot **Enabled**, Flash **16MB**,
   PSRAM **OPI PSRAM**, Partition **16M Flash (3MB APP/9.9MB FATFS)**.
4. Upload, then unplug and replug the board.

Hold **BOOT**, speak, release.

## Settings

| Setting | Where | Default |
|---|---|---|
| Claude model | `TARA_MODEL` env var | `claude-haiku-5-5` |
| Whisper model | `TARA_WHISPER` env var | `base.en` (`small.en` is more accurate) |
| Personality | `SYSTEM_PROMPT` in `server.py` | short, spoken answers |
| Volume / mic gain | `VOLUME`, `MIC_GAIN` in the sketch | 85 / 3 |
| Max recording | `MAX_SECONDS` in the sketch | 10 s |

## Next

- A room node in the wall dock: temperature, humidity and desk presence, with a
  dashboard, and the docked charm waking when you sit down ([plan](docs/room-node-plan.md)).
- A vibration motor for notifications, and the v3 case (speaker grille position,
  splash resistance).
- Later: offline voice notes on the SD card, cellular.

## License

MIT for everything in this repo (see [LICENSE](LICENSE)), except Espressif's
`es8311` codec driver in `firmware/tara_v0/` (Apache 2.0). The firmware fork is
Apache 2.0, like Meta's SDK.
