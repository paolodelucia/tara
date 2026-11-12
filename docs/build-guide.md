# Tara charm: build to-do (after measuring)

Everything left to turn the board into a finished charm on a lanyard with a wall
dock. **You** = Paolo, **Claude** = done in a Claude Code session. Each step ends
with a ✅ check; don't move on until it passes.

No deadline (the hackathon was dropped on Nov 12). If time runs
short, phases 1 to 3 give a working battery charm (in the stock case, battery
taped inside) and the rest can follow.

---

## Phase 0: Measurements (you, with calipers)

Take each one twice. Photos of the caliper readings are fine.

1. Front shell outside: **width**, **height**, **corner radius** (eyeball it against a coin).
2. Front shell + board **thickness** (from the screen face to the rim's top).
3. **Rim**: how high it sits above the board, and the depth/width of the lip or groove where the old back cover sat.
4. **Brass posts**: centre-to-centre spacing for each pair (across and up-down), and each post's distance from the nearest outer edges.
5. **Tallest parts on the board's back**: the **speaker frame** height, the BAT socket height, anything else near the battery area.
6. **Speaker centre** and **MIC hole**: distance from two edges of the shell (say, left and bottom with the screen upright, seen from the back).
7. **Openings on the side** (USB-C, PWR, BOOT): do any of them cross the line where the old back cover met the shell? If yes, measure their position and size.
8. **One stock screw**: thread diameter, length, head diameter.
9. **Old back cover** (if you still have it): its thickness, and how it locates on the shell (lip, tabs, just screws).

✅ Send the numbers to Claude in one message.

---

## Phase 1: Firmware before any battery (Claude + you)

The 100 mA charge limit is built and committed (`charm` branch, `28be540`) but
not on the board yet.

1. **You**: plug the board into the laptop with **no battery attached**.
2. **Claude**: flash it and check the boot log says `charge current set to 100 mA`.

✅ The log shows the 100 mA line. Only then may a battery go near the board.

---

## Phase 2: Battery hookup (you, at the Bain lab)

Bring: the board, one 300 mAh cell, the CON-JST-PH-MF2. From the lab: multimeter,
fine-tip iron, flux, heat-shrink (1.5–2 mm), hot glue.

1. Check the battery: no puffing or dents; the multimeter reads **3.7–3.9 V** on its plug.
   ✅ Battery looks and reads healthy.
2. Find **+** on the board's BAT socket: USB in, no battery, multimeter across the two pins (~4.2 V); confirm it matches the **+** printed on the board.
   ✅ + is marked.
3. Unplug USB. Cut the MF2's **female** lead to ~4 cm, slide on heat-shrink, solder red to **+** and black to **−** on the socket's feet, one at a time. Shrink the tubing.
   ✅ No solder bridge between the pins (check continuity: there should be none).
4. Hot-glue over the joints so pulling the wire can't rip the socket off.
5. Plug in the battery (red to red). Then plug in USB.
   ✅ The screen shows the battery and charging.
6. **First charge, supervised:** stay nearby, touch the battery every few minutes. Warm is fine; hot means unplug right away. At 100 mA a full charge takes about 3–3.5 h.
   ✅ It finishes charging and the battery never got hot.
7. Unplug USB and use it on battery.
   ✅ It runs, joins Wi-Fi, a voice note gets a spoken reply.

**Runtime test (optional, useful):** note the battery % and time, use it normally, check again a few hours later. Tell Claude the numbers.

---

## Phase 3: Printable files (Claude)

1. **Claude**: turn the measurements into an **OpenSCAD** model (every size a named
   value at the top) for:
   - the **back cover**: rounded edges, battery pocket, JST socket spot, motor pocket, hidden magnet pockets (15 × 1 mm under a 0.6 mm skin), speaker grille, MIC hole, deep screw pockets, keyring tab top centre, wire channel between two posts
   - a **fit-test ring**: just the cover's rim and screw holes, about 15 minutes to print
   - the **wall dock**: plate, ledge, two 10 × 3 mm countersunk magnet seats, cable clip, Command strip area
2. **Claude**: update the 3D mockup to match, and export **STL** files.

✅ You have three STLs: `fit-test.stl`, `back-cover.stl`, `wall-dock.stl`.

---

## Phase 4: Print (you, at the lab)

1. **Fit test first** (PLA is fine): print `fit-test.stl`, press it onto the shell, try a screw in each post.
   ✅ It seats without force and doesn't rattle; all four screws line up. If not, tell Claude what's off by how much.
2. **Back cover**: **ABS on an enclosed printer**, or PETG. Not PLA.
   - Print **back face down** (keyring tab flat on the bed).
   - 0.2 mm layers, 4 walls, 30% infill, **100% infill in the tab**.
   - Supports only where the slicer insists (the pocket ledges should bridge).
   ✅ The tab doesn't flex when you tug it; the magnet pockets are clean.
3. **Wall dock**: PLA, back face down.
   ✅ The cable clip holds your USB-C cable.

---

## Phase 5: Vibration motor (Claude + you)

1. **Claude**: confirm a free header pin the Muse firmware doesn't use (likely **IO17 or IO18**), and add a short buzz for "reply done" and notifications.
2. **You**: test on a breadboard first (motor, 2N2222A, 1N4148 across the motor, 1 kΩ to the base, wiring diagram in `parts-order-nov-2026.md`).
   ✅ It buzzes when Claude's test command runs.
3. **You**: solder the small circuit with thin wires to the header pin, 3V3 and GND. Heat-shrink everything.
   ✅ Buzzes on a voice reply.

---

## Phase 6: Assemble the charm (you)

1. **Magnets in the cover:** before gluing, put a dock magnet against the outside of each pocket and note which way the disc wants to face. The two charm magnets must face **opposite** ways. Superglue them in.
   ✅ The cover sticks to the dock plate one way up and **pushes away** when flipped.
2. Battery in its pocket on a bit of foam tape; plug it into the JST socket.
3. Motor into its pocket, wires routed so nothing crosses the screw posts.
4. Route the battery wire through the channel between the two posts.
5. Close the cover with the stock screws, through the deep pockets. Don't overtighten (plastic).
   ✅ The cover sits flush, nothing rattles, no wire pinched.
6. Full test:
   ✅ Turns on with PWR. ✅ Voice note works (the mic hears you through the hole). ✅ The reply is clearly audible (the speaker grille is lined up). ✅ Buzz works. ✅ Charges over USB-C.
7. Split ring through the tab, lanyard on.

---

## Phase 7: Wall dock (you, with Claude for the firmware part)

1. Seat the two 10 × 3 mm countersunk magnets (small M3 flat-head screws, or glue), poles matching the charm.
   ✅ The charm snaps on the right way up, centred on the ledge.
2. Command strip on the back, stick it at a comfortable height near an outlet.
3. Run the USB-C cable through the clip and down to the charger.
   ✅ The charm docks, you plug the cable into its side, it charges.
4. **Claude (optional)**: a "home base" mode: on USB power the screen stays on with a clock; off USB it goes back to pocket mode.

---

## Phase 8: Demo readiness (no date)

1. Charge both batteries fully the night before.
2. Test on **eduroam** on campus (run `python send_eduroam.py` if you haven't).
   ✅ It joins eduroam by itself and gets a spoken reply.
3. Backup network: phone hotspot (2.4 GHz / "Maximize Compatibility") saved on the charm.
4. Write a 30-second demo script: lift the charm off the lanyard, ask Tara something, she answers out loud, buzz, show it docking on the stand.
5. Check the relay's daily cap won't run out mid-demo (30,000 characters is plenty for a day).

---

## Later (not needed for the charm)

- **Room sensor ESP32**: solder the BME280's header pins, wire BME280 + PIR to an ELEGOO board (pins in `parts-order-nov-2026.md`), Claude writes the code, later expose it to Tara through Muse's home-network tunnel.
- Commit the case files (OpenSCAD + STLs) to the public `tara` repo.
- Offline voice notes on a microSD card when there's no Wi-Fi.
- Cellular (LTE module) for a phone-free day.

## Where things are

- Parts list and wiring: [parts-list.md](parts-list.md)
- Case and dock print files: [case/](../case/)
- Charm firmware and flashing: [charm/README.md](../charm/README.md)
