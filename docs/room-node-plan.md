# Room node + home dock: PRD (draft, Nov 12 2026)

Planning notes for the room node's **software**. Parts and wiring are in
[parts-list.md](parts-list.md); the charm build steps are in
[build-guide.md](build-guide.md); the case and dock are in [case/](../case/).

## Goal

Log the temperature, humidity and presence at Paolo's desk into his "life OS",
and tie it into Tara: when the charm sits in its dock and Paolo sits down, the
charm's screen wakes up.

## Decisions so far

| Question | Decision |
|---|---|
| Life OS app | **Not picked yet.** Keep the raw room data *outside* the life OS; only push daily summaries into it later (Notion's API is ~3 requests/s, no batch writes, 10,000-result cap, so it can't hold minute data). |
| Where the sensor lives | **Inside the wall dock**, which hangs **by the desk**. BME280 in its own vented pocket at the **bottom**, ESP32 at the top, a wall between them, PIR window facing the desk chair. One USB cable powers the node and charges the charm. One-time calibration offset against a cheap thermometer. *Tell the STL session this.* |
| Presence | PIR logs "at desk" stretches (the dock is at the desk, so this measures **desk time**, not room time). |
| Dock tie-in | Motion while the charm is docked (on USB power) wakes the charm's screen. Not docked: ignored. |
| Output | A **dashboard page**: live readings, 24 h / 7 d / 30 d graphs, desk-time per day. |
| History | **Every minute for 30 days, then hourly averages forever.** ✅ agreed |
| Data stack | **A: own page on Google Cloud** (picked Nov 12). B kept below for reference. |

## Hardware (already owned)

- ELEGOO ESP32-WROOM-32 (classic ESP32, CP2102, Arduino "ESP32 Dev Module").
- BME280 SENS-64-3.3V (I2C 0x76 or 0x77): VCC 3.3V, GND, SDA GPIO21, SCL GPIO22.
- PIR SENS-PIR-D203S (3–15 V; output type still to confirm with a multimeter):
  VCC 3.3V, GND, OUT GPIO27.
- Home Wi-Fi (2.4 GHz). The charm is on the same network at home.

## Architecture A: your own page (Google Cloud, same project as the TTS relay)

```
 Dock by the desk                                Google Cloud (relay project)
┌──────────────────────┐   HTTPS POST /reading   ┌──────────────────────────────┐
│ ESP32 room node      │ ──── every 60 s ──────▶ │ Cloud Run "room-api"         │
│  BME280  PIR         │   Bearer token          │  max 1 instance, rate limit  │
│  buffers if offline  │                         │        │                     │
└────────┬─────────────┘                         │        ▼                     │
         │ LAN UDP "motion"                       │ Firestore                    │
         │ (shared secret)                        │  minutes/  (TTL 30 days)     │
         ▼                                        │  hours/    (kept forever)    │
┌──────────────────────┐                          │        │                     │
│ Tara charm (docked)  │                          │        ▼                     │
│  on USB power? ──▶   │                          │ GET /  dashboard page        │
│  wake screen         │                          │ GET /now  JSON (for Tara,    │
└──────────────────────┘                          │   later the life OS)         │
                                                  └──────────────────────────────┘
```

- **Node firmware (Arduino):** read BME280 + PIR, POST a JSON reading each minute
  (`t`, `rh`, `p`, motion seconds in that minute), keep up to ~a day in RAM if Wi-Fi
  or the API is down, send a UDP "motion" packet on the LAN when the PIR fires.
- **room-api (Flask on Cloud Run, like the relay):** checks the token, writes the
  minute doc, updates that hour's average, serves the dashboard and `/now`.
- **Cost:** ~1,440 writes/day plus 24 hourly updates, well under Firestore's free
  20,000 writes/day. Max 1 instance and a per-token rate limit keep it under the
  $5/day rule even if the token leaks. Free trial billing, don't upgrade.
- **Dashboard:** works from anywhere (phone, campus). Needs a login or secret link.
- **Pros:** fully yours, demo/portfolio piece, first brick of a custom life OS,
  no extra hardware, works away from home.
- **Cons:** you build storage, rollups, charts and auth yourself; needs internet.

## Architecture B: Home Assistant + ESPHome (Raspberry Pi 5 at home)

```
 Dock by the desk                     Raspberry Pi 5 (always on, home LAN)
┌──────────────────────┐  ESPHome    ┌──────────────────────────────────────┐
│ ESP32 room node      │  native API │ Home Assistant OS                    │
│  ESPHome YAML:       │ ──────────▶ │  recorder: 30 days of states         │
│  bme280 + PIR        │  (LAN)      │  long-term statistics: hourly forever│
│  (binary_sensor      │             │  dashboard (Lovelace) + phone app    │
│   device_class:      │             │  automation: desk motion ──┐         │
│   motion)            │             │                            │         │
└──────────────────────┘             └────────────────────────────┼─────────┘
                                                                  │ HTTP on LAN
                                                                  ▼
                                               ┌──────────────────────────────┐
                                               │ Tara charm (docked): wake    │
                                               └──────────────────────────────┘
 Away from home: Tailscale (free) or Nabu Casa (paid) to see the dashboard.
```

- **Node firmware:** ~30 lines of ESPHome YAML, no C++. Auto-discovered by HA.
- **Retention** matches the decision almost out of the box (recorder
  `purge_keep_days: 30`; long-term statistics are hourly and kept forever).
- **Pros:** fastest to working graphs, automations and a phone app for free, all
  local, huge ecosystem (lights, plugs, etc. later).
- **Cons:** buy and run a Pi 5 (~$100+ with power, case, SD), generic-looking
  dashboards, less "built by you", remote access needs Tailscale or a subscription.

## Charm side (both architectures)

- New code on the `charm` branch of `muse-gadget-sdk`: listen on a UDP port (A) or
  a tiny HTTP endpoint (B) for "motion", check the shared secret, and if the
  AXP2101 reports USB power present (= docked), wake the screen. Small; no change
  to Muse itself.
- Later: Tara answers "how warm is my room?" by fetching `/now` (A) or the HA API
  (B), possibly through the Muse home-network tunnel.

## Open questions for the next session

1. PIR output: confirm it's a clean digital HIGH at 3.3 V supply (multimeter).
2. Dashboard access: secret link, Google sign-in, or home-only?
3. Which life OS gets the daily summary (decide later; data is stored either way).

## Build order (architecture A)

1. Breadboard: BME280 + PIR on an ELEGOO ESP32, print readings over serial
   (`friday-repo/firmware/room_node/room_node.ino`). ✅ check
2. Node → room-api on Cloud Run. ✅ check
3. Dashboard page with 24 h graph. ✅ check
4. Rollups and retention (30 days minute, hourly forever). ✅ check
5. Charm: wake-on-motion when docked. ✅ check
6. Move the node into the printed dock, calibrate the temperature offset. ✅ check
