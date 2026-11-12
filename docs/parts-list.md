# Parts order and build notes (Nov 2026)

Handoff for planning builds with these parts. Covers what was ordered, what each
part is for, what comes from the lab instead, what was skipped and why, and the
board facts that the designs depend on.

## The order (Abra Electronics, Montreal)

Purolator Ground, about 1 to 3 days to Kingston. Subtotal **CA$49.06**, plus
CA$17.45 shipping and 13% tax: about **CA$75** total. (Abra has a CA$45.50
minimum order.)

| Qty | Code | Part | Price | For |
|---|---|---|---|---|
| 2 | BAT-LIPO-3.7-300 | 3.7 V 300 mAh LiPo, 32 × 20 × 6 mm, protection circuit, JST-PH 2.0 plug | 2 × 8.49 | Charm battery, plus a spare |
| 1 | CON-JST-PH-MF2 | 2-pin JST-PH 2.0 male + female pair, 20 cm wire | 0.99 | Battery adapter on the charm (see "Battery hookup") |
| 1 | MOT-112 | 3 V coin vibration motor, 8 × 2.7 mm | 1.65 | Charm buzz for notifications and "done" |
| 2 | 2N2222A | NPN transistor, 0.8 A, 40 V, TO-92 | 2 × 0.76 | Drives the motor (one spare) |
| 1 | MAG-N-25 | Neodymium discs, 15 × 1 mm, pack of 5 | 3.37 | Charm side of the magnetic wall dock |
| 1 | MAG-N-10X3-CS | Countersunk ring magnets, 10 × 3 mm, 4 mm hole, pack of 10 | 3.85 | Dock side, screwed into the printed dock |
| 1 | SENS-64-3.3V | BME280: temperature, humidity, pressure; I2C or SPI; 3.3 V; 11.5 × 15 mm | 14.75 | Room sensor ESP32 |
| 1 | SENS-PIR-D203S | PIR motion sensor, 3 to 15 V, 3 to 7 m, 120°, 20 × 30 mm | 5.95 | Room sensor ESP32 |

## Free from the lab (Bain lab / ECE lounge)

- **1N4148 diode** and a **~1 kΩ resistor**: the rest of the motor circuit
- **Heat-shrink**: insulate every battery and motor solder joint (a bare LiPo wire
  touching the board can short and get hot)
- **Hot glue**: strain relief over the battery socket joints
- **Header pins**, if the BME280 or PIR come without them soldered
- **Soldering station, flux, multimeter**
- **PETG filament** for the charm's case (PLA is fine for the wall dock)
- Optional: a ready-made **2-pin MX1.25 / PicoBlade lead** (also check the board's
  box). If there's none, use the solder route below.

## Skipped, and why

| Item | Why not |
|---|---|
| 500 mAh LiPo (37.89 × 29.62 × 5 mm) | Doesn't fit between the case's screw posts (33 × 22 mm of clearance) |
| Digital caliper | The lab has calipers to borrow |
| M2/M3/M4 screw kit (CA$39.95) | The case is planned with deep screw pockets so the original screws still reach |
| MX1.25 connector kit (Amazon) | Not needed with the solder route; Abra doesn't sell 2-pin MX1.25 |
| Slide switch SSW-100 | Rated 0.1 A, far below the board's draw; the PWR button turns the board off |
| 10 × 5 mm magnets | Too thick for the charm; the 10 × 3 countersunk ones suit the dock |
| Pogo pins / Hall sensor | The dock just plugs a USB-C cable in; the firmware already sees USB power |
| microSD card | Nothing uses it yet (possible later: offline voice-note queue, logs) |

## Board facts the designs depend on

Waveshare ESP32-S3-Touch-AMOLED-1.8, **V2** (CO5300 display, ES8311 audio, AXP2101
charger), now running Meta's Muse gadget firmware as Tara's charm.

- **Board (PCB):** about 45.2 × 37.6 mm. **Stock case outside:** roughly 52 × 47 mm
  (estimated from photos: measure before printing).
- **Screw posts:** four brass threaded inserts (likely M2). The clear space between
  them for a battery is about **33 × 22 mm**.
- **Battery socket:** white **2-pin MX1.25** marked **BAT**, with **+** and **−**
  printed beside it.
- **Expansion header** (along one edge): IO42, IO41, IO40, IO39, IO38, IO18, IO17,
  SDA/IO15, SCL/IO14, RXD, TXD, GND, 3V3, GND, VBUS. **Don't use IO19/IO20**:
  they're the USB data lines. IO14/IO15 are the board's shared I2C bus.
- Already on the board: speaker, microphone, 6-axis IMU (no compass, so magnets
  are fine), RTC, microSD slot, BOOT and PWR buttons.

## Build plans

### 1. Battery hookup (charm)

Solder the **female half of CON-JST-PH-MF2** (the side a battery plugs into) to
the two feet of the board's BAT socket. Then either 300 mAh battery clicks in
without cutting its wires.

1. Find + and −: USB plugged in, no battery, multimeter across the BAT pins
   (the charger puts out about 4.2 V). Confirm it matches the silkscreen.
2. Unplug USB. Solder one wire at a time (fine tip, flux), heat-shrink each joint.
3. Hot-glue over the joints for strain relief.
4. Before the first battery: check its red wire lands on +.

**Charging limit:** the 300 mAh cells must charge at **150 mA or less** (Abra's
listing). The Muse firmware doesn't set the charge current yet: **add that limit
in the firmware before the first charge.**

### 2. Charm case (3D printed)

A printed **back cover** replaces Waveshare's, deeper to hold the battery.
The finished design and print files are in [case/](../case/).

- Battery pocket for **32 × 20 × 6 mm** between the posts; the battery wire leaves
  sideways through a gap between two posts (only ~1 mm spare on the length).
- **Deep screw pockets** so the original screws reach the brass inserts.
- **Keyring tab** built into the back floor, for a 15 to 20 mm split ring and a
  lanyard. Print back face down so the tab's layers can't peel.
- **15 × 1 mm magnets** set into the back floor for the dock.
- Room for the **vibration motor** and its transistor.
- **PETG**, not PLA (heat, and there's a LiPo inside).
- Still to measure: post centre-to-centre spacing, inner length and width,
  speaker and USB-C positions, and whether any openings cross the case seam.

### 3. Magnetic wall dock

A printed wall mount, like a thermostat: the charm snaps on with magnets and you
plug its USB-C cable in (or the dock holds the USB-C plug so dropping the charm
in connects it). **10 × 3 mm countersunk magnets** screwed into the dock, lined up
with the 15 × 1 mm discs in the charm; set the polarity so it only docks one way.
When the charm sees USB power it can switch to a "home base" mode (clock, always
on).

### 4. Vibration motor (charm)

```
3V3 ──┬──────────────┐
      │              │
   1N4148          motor (+)
  (cathode ↑)      motor (−)
      │              │
      └──────┬───────┘
             │
          collector
 GPIO ─ 1 kΩ ─ base   2N2222A
          emitter
             │
            GND
```

- Use a free header pin such as **IO17 or IO18** (check it's unused by the Muse
  firmware first).
- The motor draws ~70 mA: never wire it straight to a GPIO.
- **Check the 2N2222A pin order** (E-B-C) on its datasheet; it varies by maker.
- Firmware: a short buzz on reply-done and notifications.

### 5. Room sensor ESP32 (ELEGOO ESP32-WROOM-32)

Temperature, humidity, pressure and motion for the room, later reachable from Tara
through Muse's home-network tunnel.

| Part | Pin | ESP32 |
|---|---|---|
| BME280 | VCC | 3.3V |
| BME280 | GND | GND |
| BME280 | SDA | GPIO21 |
| BME280 | SCL | GPIO22 |
| PIR D203S | VCC | 3.3V |
| PIR D203S | GND | GND |
| PIR D203S | OUT | GPIO27 (any free input) |

- BME280 I2C address is **0x76** or **0x77** (run an I2C scan first).
- Mount the BME280 **away from the ESP32** (a short cable) or it reads 1 to 3 °C
  warm.
- The PIR listing doesn't say whether its output is digital: on day one, watch the
  pin in the serial monitor. A clean HIGH/LOW on motion means it's digital.
- Ideas: "welcome back" on motion, alerts for cold or humid air, IR control later.

## Related notes

- Battery buying notes: [battery.md](battery.md)
- Charm firmware, flashing and the relay: [charm/README.md](../charm/README.md)
