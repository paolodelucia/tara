# Battery for the Waveshare ESP32-S3-Touch-AMOLED-1.8

The board has its own charger (the AXP2101), so a battery is the only thing to
buy: it charges over the same USB-C cable and the board switches to it when you
unplug. No separate charger or voltage converter.

## What to buy

1. **A single-cell ("1S") 3.7 V LiPo with a protection circuit.** Skip bare
   cells (no small board under the tape) and anything puffy or dented.
   - **Inside the case:** at most **3.85 mm thick x 24 x 28 mm**. The size is
     the model number: `302025` (3.0 x 20 x 25 mm) or `352025` fit, about
     150-200 mAh.
   - **Easier for now:** a flat **500-1000 mAh** pack taped to the back
     (`503035`, `603450`). Lasts longer and is safer to charge (see below).
2. **The right plug.** The board's socket is **MX1.25, 2-pin** (1.25 mm pitch,
   small and white). Hobby batteries usually come with **JST-PH 2.0**, which
   doesn't fit: buy an **MX1.25 2-pin pigtail** and some **heat-shrink**, and
   solder it on at the Bain lab.
3. Optional: double-sided foam tape or Kapton tape to mount it.

The Bain lab (Queen's ECE maker space) doesn't stock LiPos (fire hazard), but
has multimeters, soldering, 3D printing and PCB milling. Online option: Adafruit
#1317 (150 mAh) from DigiKey Canada; check its listed dimensions against the
limit above, and expect a JST-PH plug to swap.

## Safety

1. **Check polarity before plugging in.** With a multimeter, the battery's
   **+** must go to the **+** on the board's socket. Wire colours on cheap leads
   are sometimes swapped, and backwards can kill the board.
2. **Charge current.** Meta's Muse firmware reads the battery but never sets
   the charge current, so the board charges at the AXP2101's default, which
   isn't confirmed. With a 500 mAh or bigger cell that's very likely fine. For
   a 150-200 mAh in-case cell, set a limit in firmware first (about 100 mA,
   register-level in `muse_pmu.c`), and until then don't leave it charging
   unattended.

## What to expect

- **PWR** turns the board on and off.
- With the Muse firmware the screen turns off on battery and the chip
  light-sleeps between button presses, so it lasts much longer than the
  Tara v0 firmware. It shows the battery percentage, so time a full charge to know.
