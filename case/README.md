# Tara charm case: print files

`charm_case.scad` is the source (OpenSCAD; every size is a named value at the
top). The STLs are exported from it:

| File | What | Material | Time (approx) |
|---|---|---|---|
| `fit-test.stl` | Rim seat + lip + 4 screw rings, to check the fit first | PLA or PETG | ~15 min |
| `back-cover.stl` | The back cover: battery, magnets, motor, JST socket, grille, keyring tab | **PETG** | ~1 h |
| `wall-dock.stl` | Wall plate with ledge, 2 magnet seats, cable clip | PLA | ~1.5 h |

## Print settings

- **Orientation:** as exported. The cover and dock print **back face down**
  (keyring tab flat on the bed). If the slicer floats the fit-test, use
  "drop to bed" / "place on face".
- 0.4 mm nozzle, **0.2 mm layers**, **4 walls**, 30% infill.
- **Keyring tab:** 100% infill (a modifier in the slicer, or just 100% for the whole cover; it's small).
- **Supports: off.** The screw recesses and the lip ledge are designed to print without them.
- PETG: 230–245 °C nozzle, 70–80 °C bed, slow first layer, glue stick or a textured sheet.

## Order

1. **Fit test.** Press it onto the shell, put M2 × 10 screws in all four posts.
   - It should seat flat without force and not rattle.
   - If the lip is too tight, change `CLEAR` (0.15) to 0.25. Too loose: 0.08.
   - If a screw hole misses a post, measure how far off and change `POST_X` / `POST_Y`.
2. **Back cover** in PETG.
3. **Wall dock** in PLA.

## Assembly notes

- **Screws:** M2 × 10 socket head from the lab kit (1.5 mm hex key). They bite
  ~4 mm into the brass posts. Snug, don't crank.
- **Blocked screw holes (print 1):** the counterbore ceiling sagged into the
  hole. Clear it by twisting a 2–2.5 mm drill bit through by hand from the
  head side (no power drill: PETG melts and gums up). Files exported after
  Nov 12 use sacrificial bridges there and shouldn't need this.
- **Magnets:** set the dock's two 10 × 3 mm magnets first, opposite ways up
  (glue, countersink out on top, in at the bottom). Then sit a 15 mm disc on
  each dock magnet, mark its exposed face with a Sharpie, and glue it into the
  matching cover pocket (top to top) with the mark facing **into** the cover.
  A small dot of superglue or 5-minute epoxy; the battery's foam tape covers
  them too.
- **Battery** on a strip of foam tape between the four corner ribs, wires out
  of the **top** end, over to the JST socket in the upper-left cradle.
- **Motor** stands on its edge in the lower-left slot (a dot of glue).
- **Hot glue** at the BAT connector must stay below the rim: the battery sits
  just 0.5 mm above it.

## Estimates to check

- **Speaker grille and mic hole** positions come from photos, not measurements.
  If the old back cover has holes, copy their positions into `SPEAKER_XY` /
  `MIC_XY` and re-export.
  - **Nov 12, black ABS print:** Paolo found the speaker grille is in the
    wrong spot. Fine for now; fix it in the next case (v3): measure the
    speaker's centre from two shell edges and update `SPEAKER_XY` (and check
    the grille still clears the battery strip and screw boss).
  - **Likely cause (from the build photos):** the grille and mic hole are
    mirrored left-right. Seen from behind, the board has its speaker top right
    and its mic bottom right; the printed cover, seen from behind, has the
    grille top left and the mic hole bottom left. The cover prints back face
    down, so its outside is the model seen from below, which flips x. For v3,
    try flipping the sign of x in `SPEAKER_XY` and `MIC_XY` first, then check
    against the board.
- **Ideas for v3:** splash resistance (gasket groove in the rim seat, inside
  recesses for stick-on acoustic vents over the grille and mic, a USB-C dust
  plug), and the grille fix above.
- **Corner radius:** `SHELL_R` = 6.5 for the outer corners and `LIP_R` = 4.08 for
  the lip, both checked with fit-test prints (6.0 left the corners slightly proud).
- **Wall dock:** the front lip sits `DOCK_FRONT_GAP` (1.5 mm) in front of the
  screen, for a charm up to about 20.5 mm thick. Its inside face is a 45° slope so
  it prints without supports.

Charm thickness with this cover: about **19 mm** (10.6 shell + 8.4 cover).
