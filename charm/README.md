# The charm: Muse gadget firmware for the Waveshare ESP32-S3-Touch-AMOLED-1.8

The charm runs Meta's open-source Muse gadget firmware
([facebookincubator/muse-gadget-sdk](https://github.com/facebookincubator/muse-gadget-sdk))
with a few changes of ours, published as a fork:
**[paolodelucia/muse-gadget-sdk](https://github.com/paolodelucia/muse-gadget-sdk), branch `charm`**.

What the `charm` branch adds on top of Meta's SDK:

| Change | Files | Why |
|---|---|---|
| Spoken replies | `components/muse/muse_tts_relay.c`, a hook in `muse_chat_session.cpp` | Muse only sends gadgets text. Each finished reply goes to our [relay](../relay/), and the MP3 that comes back plays through Meta's decoder. If the relay fails, the reply just shows as text. |
| Campus Wi-Fi (eduroam) | `main/eduroam.c`, `main/certs/queens_eduroam_ca.pem` | WPA2-Enterprise (PEAP/MSCHAPv2) for Queen's University. The login is only sent to a server that proves it's Queen's. Adapt the realm, server name and CA for another school. |
| Battery charge limit | `components/muse/muse_pmu.c` | Sets the AXP2101 charger to 100 mA at boot, safe for a small 300 mAh cell. |
| Console checks | `main/muse_glue.c` | `>charge` reads the charge current back, `>eduroam=status` shows the stored login name, `>wifi` lists saved and seen networks. |
| Memory fixes for eduroam | `main/app.c`, `main/eduroam.c` | Enterprise Wi-Fi leaves little internal RAM, so eduroam waits for audio to start first, and one task falls back to a smaller stack. |

Live voice calls stay **off** (`sdkconfig.local`): on this board they run out of
DMA memory at boot.

## Tools (`tools/`)

Built on Windows, with ESP-IDF in WSL (Ubuntu 24.04), because that's what worked
here (Docker Desktop didn't).

- `build.sh`: copies the SDK into Linux, adds `sdkconfig.local` and your
  `secrets.local`, builds, and copies the firmware back to `tools/firmware/`.
- `flash.py`: writes it to the board with esptool (`--erase` the first time).
- `send_token.py`: gives the board your Muse SDK token over USB. The token never
  goes in a file or the firmware.
- `send_eduroam.py`: stores a campus Wi-Fi login on the board (`--forget` erases it).
- `capture_log.py`: records the board's log to a file, for debugging.
- `secrets.local.example`: template for your relay's URL and token.

## Build and flash

You need: Windows with WSL Ubuntu 24.04, ESP-IDF **v6.0.3** installed in WSL at
`/root/esp/esp-idf-v6.0.3`, Python 3.12 on Windows, and a Muse account.

In **cmd**, from this repo's `charm` folder:

1. `git clone -b charm https://github.com/paolodelucia/muse-gadget-sdk.git`
   ✅ A `muse-gadget-sdk` folder appears next to `tools` (git-ignored here).
2. `cd tools`, then `py -3.12 -m venv venv`, `venv\Scripts\activate`,
   `pip install -r requirements.txt`
3. Optional, for spoken replies: deploy your own [relay](../relay/), then copy
   `secrets.local.example` to `secrets.local` and fill it in.
4. `wsl -d Ubuntu-24.04 -u root -- bash build.sh` (about 5 minutes)
   ✅ It ends with "Firmware ready" and says whether spoken replies are on.
5. Plug in the board with a data cable. `python flash.py --erase` the first time,
   `python flash.py` after that.
   ✅ "Hash of data verified". If it can't connect: hold BOOT, tap PWR, release.
6. Unplug and replug. Get a token at https://gadgets.muse.ai/settings/sdk-tokens
   (read the Gadget SDK Terms), then `python send_token.py` and paste it.
   ✅ "Board says: @sdk_token ok".
7. In the Muse app: Settings > Devices > Developer mode on, then Add Device and
   pick `MuseGadget-XXXXXX`.

Talk: **hold BOOT**, speak, release. Reflashing keeps the token, pairing and Wi-Fi.

## Notes

- Muse SDK tokens are for personal, non-commercial use.
- Saved logins (Wi-Fi, eduroam) live in the board's flash unencrypted: anyone who
  gets the board and a USB cable could read them.
- The changes in the fork are Apache 2.0, like Meta's SDK.
