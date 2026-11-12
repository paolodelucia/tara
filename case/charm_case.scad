// Tara charm case: printed back cover, fit-test ring and magnetic wall dock
// for the Waveshare ESP32-S3-Touch-AMOLED-1.8 (V2) in its stock front shell.
//
// Units: mm. Every size is a named value below: change one, press F6, export.
// Pick what to build with `part` ("cover", "fit_test", "dock", "all"), or from
// the command line:  openscad -D part="\"cover\"" -o back-cover.stl charm_case.scad
//
// Cover frame (as you hold it to screw it on): looking at the BACK of the board,
// header pins (top edge) up, x to the right, y up, z out of the back. z = 0 is
// the cover's outer back face, which also goes face-down on the printer bed.

part = "all";

// ---------------------------------------------------------- measured (calipers)
SHELL_W     = 37.70;  // front shell, outside width
SHELL_H     = 45.16;  // front shell, outside height (pin row is the top)
SHELL_R     = 6.5;    // outside corner radius (fit test 1 at 6.0: corners slightly proud)
LIP_R       = 4.08;   // lip's outside corner radius: fit test 1 fit perfectly at this (6.0 - 1.92)
RIM_WALL    = 1.92;   // shell wall thickness at the rim
POST_X      = 24.0;   // brass posts, centre to centre, across
POST_Y      = 35.66;  // brass posts, centre to centre, up-down
POST_D      = 3.17;   // brass post outside diameter
POST_PROUD  = 0.2;    // how far the posts stand above the rim ("very slightly")
LIP_T       = 1.0;    // old cover's lip: wall thickness
LIP_H       = 1.0;    // old cover's lip: how far it goes into the shell
// The board is 5 mm below the rim and the BAT connector reaches the rim, so
// nothing on the board rises above the rim plane.

// ---------------------------------------------------------- parts that go inside
BAT_W = 20; BAT_L = 32; BAT_T = 6.0;   // Abra BAT-LIPO-3.7-300, standing upright
BAT_FOAM   = 0.3;     // foam tape under the battery
ABOVE_RIM  = 0.5;     // gap between the rim plane and the battery (hot glue, wires)
MAG_D = 15.0; MAG_T = 1.0;             // MAG-N-25 discs, inside the floor
MAG_SKIN   = 0.6;     // plastic left over the magnets on the outside
MAG_Y      = 8.6;     // the two magnets sit at y = +MAG_Y and -MAG_Y
MOTOR_D = 8.0; MOTOR_T = 2.7;          // MOT-112, stands on its edge in a slot
JST_W = 6.4; JST_D = 5.0;              // JST-PH 2-pin female housing (MF2), cradle inside size

// ---------------------------------------------------------- screws (lab kit, M2 x 10 socket head)
SCREW_L      = 10;
SCREW_HOLE   = 2.4;   // clearance for M2
HEAD_D       = 4.2;   // counterbore for a 3.8 mm socket head
HEAD_DEPTH   = 2.2;   // counterbore depth (head sits flush); keep it a multiple of LAYER
LAYER        = 0.2;   // slicer layer height (the bridges over the counterbores use it)
BOSS_R       = 2.2;   // plastic tube around each screw inside the cover

// ---------------------------------------------------------- holes for sound
SPEAKER_XY   = [11.6, 10.5];   // speaker centre (estimate from photos)
MIC_XY       = [13.8, -12.1];  // MIC centre (estimate from photos)
GRILLE       = true;
GRILLE_HOLE  = 1.4;
GRILLE_PITCH = 2.0;   // holes sit in the free strip beside the battery, level with the speaker
MIC_HOLE     = 2.6;

// ---------------------------------------------------------- shape
FLOOR   = 1.6;
WALL    = 1.6;        // cover side wall above the rim
FILLET  = 2.5;        // rounded back edge
CLEAR   = 0.15;       // fit clearance, per side, for the lip in the shell
TAB_W = 12; TAB_UP = 9; TAB_T = 4; RING_HOLE = 4.5;   // keyring tab, top centre

// ---------------------------------------------------------- wall dock
DOCK_T      = 4.0;    // plate thickness
DOCK_SIDE   = 7.0;    // plate margin on the left of the charm
PLUG_ROOM   = 32.0;   // plate width on the right: the USB-C plug sticks out of the
                      // charm's right side, then the cable loops down to the clip
LEDGE_T     = 3.0;
LEDGE_LIP   = 4.0;    // front lip height that stops it sliding off
DOCK_FRONT_GAP = 1.5; // room between the charm's screen and the lip
DMAG_D = 10.4; DMAG_T = 3.0;           // MAG-N-10X3-CS seats (magnets glued in)
CABLE_D     = 4.0;    // USB-C cable thickness for the clip

$fn = 48;

// ============================================================ derived
DEPTH  = FLOOR + BAT_FOAM + BAT_T + ABOVE_RIM;   // cover height above the rim
INNER_W = SHELL_W - 2 * WALL;
INNER_H = SHELL_H - 2 * WALL;
LIP_OUT_W = SHELL_W - 2 * RIM_WALL - 2 * CLEAR;
LIP_OUT_H = SHELL_H - 2 * RIM_WALL - 2 * CLEAR;
POSTS = [for (sx = [-1, 1], sy = [-1, 1]) [sx * POST_X / 2, sy * POST_Y / 2]];
CHARM_THICK = 10.6 + DEPTH;   // screen face to the back of the cover
echo(str("Cover depth above the rim: ", DEPTH, " mm. Whole charm: ", CHARM_THICK, " mm."));
echo(str("Screw bite into the brass posts: ", HEAD_DEPTH + SCREW_L - (DEPTH - POST_PROUD), " mm."));

module rrect(w, h, r) { offset(r) square([w - 2 * r, h - 2 * r], center = true); }

// Outer body: rounded back edge (fillet) made from stacked slices.
module body() {
    steps = 6;
    hull() {
        for (i = [0:steps]) {
            a = 90 * i / steps;
            inset = FILLET * (1 - sin(a));
            translate([0, 0, FILLET * (1 - cos(a))])
                linear_extrude(0.01) rrect(SHELL_W - 2 * inset, SHELL_H - 2 * inset, max(0.5, SHELL_R - inset));
        }
        translate([0, 0, DEPTH - 0.01]) linear_extrude(0.01) rrect(SHELL_W, SHELL_H, SHELL_R);
    }
}

module keyring_tab() {
    y0 = SHELL_H / 2;
    difference() {
        // nothing of the tab inside the cavity (it would block the battery wires)
        hull() {
            translate([-TAB_W / 2, y0 - 6, 0]) cube([TAB_W, 1, TAB_T]);
            translate([0, y0 + TAB_UP - TAB_W / 2, 0]) cylinder(d = TAB_W, h = TAB_T);
        }
        translate([0, y0 + TAB_UP - TAB_W / 2, -1]) cylinder(d = RING_HOLE, h = TAB_T + 2);
        translate([0, 0, FLOOR]) linear_extrude(DEPTH) rrect(INNER_W, INNER_H, max(0.5, SHELL_R - WALL));
    }
}

LIP_IN_W = LIP_OUT_W - 2 * LIP_T;
LIP_IN_H = LIP_OUT_H - 2 * LIP_T;
LIP_IN_R = max(0.5, LIP_R - LIP_T);

module lip() {
    translate([0, 0, DEPTH]) linear_extrude(LIP_H) difference() {
        rrect(LIP_OUT_W, LIP_OUT_H, LIP_R);
        rrect(LIP_IN_W, LIP_IN_H, LIP_IN_R);
    }
}

// The lip sits inside the shell's rim, inward of the cover's side wall, so a
// ledge at the top of the wall carries it. Its underside is a 45 degree slope,
// so it prints without supports (the cover prints back face down).
module lip_ledge() {
    slope = (INNER_W - LIP_IN_W) / 2 + 0.01;
    difference() {
        translate([0, 0, DEPTH - slope]) linear_extrude(slope)
            rrect(INNER_W + 0.02, INNER_H + 0.02, max(0.5, SHELL_R - WALL));
        hull() {
            translate([0, 0, DEPTH - slope - 0.01]) linear_extrude(0.01) rrect(INNER_W, INNER_H, max(0.5, SHELL_R - WALL));
            translate([0, 0, DEPTH]) linear_extrude(0.01) rrect(LIP_IN_W, LIP_IN_H, LIP_IN_R);
        }
    }
}

module screw_bosses() {
    for (p = POSTS) translate([p[0], p[1], 0]) cylinder(r = BOSS_R, h = DEPTH - POST_PROUD - 0.2);
}

module screw_holes() {
    for (p = POSTS) translate([p[0], p[1], 0]) {
        translate([0, 0, -1]) cylinder(d = SCREW_HOLE, h = DEPTH + LIP_H + 2);
        translate([0, 0, -1]) cylinder(d = HEAD_D, h = HEAD_DEPTH + 1);
        // The counterbore's ceiling prints in mid-air (back face down), and a
        // round ceiling with a hole in it sags into the hole (print 1: 3 of 4
        // holes blocked). Sacrificial bridges instead: one layer bridges straight
        // across leaving a slot, the next bridges across the slot leaving a
        // square, then the round hole carries on. Nothing hangs over the hole.
        intersection() {
            translate([0, 0, HEAD_DEPTH - 0.01]) cylinder(d = HEAD_D, h = LAYER + 0.01);
            translate([-HEAD_D / 2, -SCREW_HOLE / 2, HEAD_DEPTH - 0.01]) cube([HEAD_D, SCREW_HOLE, LAYER + 0.01]);
        }
        translate([-SCREW_HOLE / 2, -SCREW_HOLE / 2, HEAD_DEPTH]) cube([SCREW_HOLE, SCREW_HOLE, 2 * LAYER]);
        // room for the post top that stands proud of the rim
        translate([0, 0, DEPTH - POST_PROUD - 0.2]) cylinder(d = POST_D + 0.6, h = 5);
    }
}

EMBED = 0.01;   // parts on the floor sink this far into it, so they fuse

module battery_guides() {
    // L-shaped corner ribs that locate the battery (the two bars overlap at the corner)
    bx = BAT_W / 2 + 0.3; by = BAT_L / 2 + 0.3;
    for (sx = [0, 1], sy = [0, 1]) mirror([sx, 0, 0]) mirror([0, sy, 0]) {
        translate([bx, by - 4, FLOOR - EMBED]) cube([0.8, 4.8, 2.5 + EMBED]);
        translate([bx - 4, by, FLOOR - EMBED]) cube([4.8, 0.8, 2.5 + EMBED]);
    }
}

module jst_cradle() {
    // left strip, upper: holds the JST-PH socket the battery plugs into
    cx = -(BAT_W / 2 + 0.3 + 0.8 + JST_D / 2 + 0.6); cy = 7;
    translate([cx, cy, FLOOR - EMBED]) difference() {
        translate([-(JST_D / 2 + 0.8), -(JST_W / 2 + 0.8), 0]) cube([JST_D + 1.6, JST_W + 1.6, 3]);
        translate([-JST_D / 2, -JST_W / 2, 0]) cube([JST_D, JST_W, 4]);
        translate([-JST_D / 2 - 1, -1.5, 1]) cube([JST_D + 2, 3, 4]);   // wire slots
    }
}

module motor_slot() {
    // left strip, lower: the coin motor stands on its edge, pressed against the floor
    cx = -(BAT_W / 2 + 0.3 + 0.8 + 2.5); cy = -8;
    translate([cx, cy, FLOOR - EMBED]) difference() {
        translate([-(MOTOR_T / 2 + 1.0), -(MOTOR_D / 2 + 1.0), 0]) cube([MOTOR_T + 2, MOTOR_D + 2, 4.5]);
        translate([-(MOTOR_T + 0.4) / 2, -(MOTOR_D + 0.4) / 2, 0]) cube([MOTOR_T + 0.4, MOTOR_D + 0.4, 5]);
        translate([-3, -1, 2.5]) cube([6, 2, 3]);   // wire exit
    }
}

module magnet_pockets() {
    for (y = [-MAG_Y, MAG_Y]) translate([0, y, MAG_SKIN]) cylinder(d = MAG_D + 0.3, h = MAG_T + 1);
}

module sound_holes() {
    strip_mid = (BAT_W / 2 + 1.1 + INNER_W / 2) / 2;
    if (GRILLE) for (i = [-1:1], j = [-3:3]) {
        x = strip_mid + i * GRILLE_PITCH; y = SPEAKER_XY[1] + j * GRILLE_PITCH;
        // only beside the battery, inside the wall, clear of the screw boss
        if (x - GRILLE_HOLE / 2 > BAT_W / 2 + 1.1 && x + GRILLE_HOLE / 2 < INNER_W / 2 - 0.3
            && norm([x - POST_X / 2, y - POST_Y / 2]) > BOSS_R + 1.0)
            translate([x, y, -1]) cylinder(d = GRILLE_HOLE, h = FLOOR + 2, $fn = 16);
    }
    translate([MIC_XY[0], MIC_XY[1], -1]) cylinder(d = MIC_HOLE, h = FLOOR + 2, $fn = 24);
}

module cover() {
    difference() {
        union() {
            difference() {
                body();
                translate([0, 0, FLOOR]) linear_extrude(DEPTH) rrect(INNER_W, INNER_H, max(0.5, SHELL_R - WALL));
            }
            screw_bosses();
            battery_guides();
            jst_cradle();
            motor_slot();
            lip_ledge();
            lip();
            keyring_tab();
        }
        screw_holes();
        magnet_pockets();
        sound_holes();
    }
}

// Fit test: just the rim seat, the lip and the four screw holes (about 15 minutes).
module fit_test() {
    t = 1.6;
    difference() {
        union() {
            translate([0, 0, DEPTH - t]) linear_extrude(t) difference() {
                rrect(SHELL_W, SHELL_H, SHELL_R);
                rrect(LIP_IN_W, LIP_IN_H, LIP_IN_R);   // reaches the lip, so they join
            }
            for (p = POSTS) translate([p[0], p[1], DEPTH - t]) cylinder(r = 3.2, h = t);
            for (p = POSTS) hull() {   // tie each screw ring to the frame
                translate([p[0], p[1], DEPTH - t]) cylinder(r = 1.5, h = t);
                translate([sign(p[0]) * INNER_W / 2, p[1], DEPTH - t]) cylinder(r = 1.5, h = t);
            }
            lip();
        }
        for (p = POSTS) translate([p[0], p[1], 0]) {
            cylinder(d = SCREW_HOLE, h = 50);
            translate([0, 0, DEPTH - POST_PROUD - 0.2]) cylinder(d = POST_D + 0.6, h = 5);
        }
    }
}

// Wall dock, printed back face down. The charm's back rests on the plate,
// its bottom edge on the ledge; magnets line up with the charm's.
DOCK_CLIP_X = SHELL_W / 2 + PLUG_ROOM - 7;   // cable clip, far right...
DOCK_CLIP_Y = 2;                              // ...and low: the cable runs down the wall from here

module dock() {
    x0 = -SHELL_W / 2 - DOCK_SIDE;      // plate's left edge
    x1 = SHELL_W / 2 + PLUG_ROOM;       // plate's right edge
    H = SHELL_H + LEDGE_T;              // plate stops at the charm's top edge (room for the ring)
    // The lip starts DOCK_FRONT_GAP in front of the charm's screen. (Before Nov 12
    // it started 1 mm *inside* the charm, so the charm couldn't sit down.) Its
    // inner face slopes at 45 degrees so it prints without supports.
    lip_z = DOCK_T + CHARM_THICK + DOCK_FRONT_GAP;
    reach = CHARM_THICK + DOCK_FRONT_GAP + LEDGE_LIP + 2;   // how far the ledge sticks out
    cy = SHELL_H / 2;                   // charm centre, above the ledge
    lw = SHELL_W * 0.7;                 // ledge width
    difference() {
        union() {
            translate([(x0 + x1) / 2, cy - LEDGE_T / 2, 0]) linear_extrude(DOCK_T) rrect(x1 - x0, H, 5);
            // ledge and its front lip
            translate([-lw / 2, -LEDGE_T, 0]) cube([lw, LEDGE_T, DOCK_T + reach]);
            hull() {
                translate([-lw / 2, -LEDGE_T, lip_z]) cube([lw, LEDGE_T, 2]);
                translate([-lw / 2, -LEDGE_T, lip_z + LEDGE_LIP]) cube([lw, LEDGE_T + LEDGE_LIP, 2]);
            }
            // cable clip: holds the cable where it turns to run down the wall
            translate([DOCK_CLIP_X, DOCK_CLIP_Y, 0]) difference() {
                translate([-(CABLE_D / 2 + 1.6), 0, 0]) cube([CABLE_D + 3.2, 8, DOCK_T + CABLE_D + 2]);
                translate([0, -1, DOCK_T + CABLE_D / 2]) rotate([-90, 0, 0]) cylinder(d = CABLE_D, h = 10);
                translate([-CABLE_D * 0.35, -1, DOCK_T + CABLE_D / 2]) cube([CABLE_D * 0.7, 10, 10]);
            }
        }
        // magnet seats, flush with the front face
        for (y = [-MAG_Y, MAG_Y]) translate([0, cy + y, DOCK_T - DMAG_T]) cylinder(d = DMAG_D, h = DMAG_T + 1);
    }
}

// Corner gauge: five labelled corners, radius 6.0 to 8.0 mm. Hold each
// against a corner of the shell (from the outside); the one with no gap and no
// overhang is the right SHELL_R.
GAUGE_RADII = [6.0, 6.5, 7.0, 7.5, 8.0];
module corner_gauge() {
    leg = 14; band = 5; t = 2;
    for (k = [0:len(GAUGE_RADII) - 1]) {
        R = GAUGE_RADII[k];
        translate([k * (leg + 4), 0, 0]) difference() {
            linear_extrude(t) intersection() {
                translate([-30 + leg, -30 + leg]) rrect(60, 60, R);   // a corner of radius R at (leg, leg)
                square([leg, leg]);
            }
            translate([-1, -1, -1]) cube([leg - band + 1, leg - band + 1, t + 2]);
            translate([1, leg - band + 1.2, t - 0.6]) linear_extrude(1)
                text(str(R), size = 2.6, font = "Liberation Sans:style=Bold");
        }
    }
}

// Picture only, not for printing: the dock with a ghost charm, USB-C plug and cable.
PORT_Z = 10.6 / 2;   // USB-C port: middle of the front shell's thickness (estimate)
module dock_with_charm() {
    color("silver") dock();
    // the charm: back cover against the plate, bottom edge on the ledge
    color("DimGray", 0.85) translate([0, SHELL_H / 2, DOCK_T]) linear_extrude(CHARM_THICK) rrect(SHELL_W, SHELL_H, SHELL_R);
    color("black") translate([-SHELL_W * 0.39, SHELL_H / 2 - SHELL_H * 0.39, DOCK_T + CHARM_THICK]) cube([SHELL_W * 0.78, SHELL_H * 0.78, 0.1]);
    // straight USB-C plug in the right side, then the cable loops down to the clip
    pz = DOCK_T + CHARM_THICK - PORT_Z;
    color("WhiteSmoke") {
        translate([SHELL_W / 2, SHELL_H / 2 - 4.5, pz - 3]) cube([22, 9, 6]);
        hull() { translate([SHELL_W / 2 + 22, SHELL_H / 2, pz]) sphere(d = CABLE_D); translate([SHELL_W / 2 + 26, SHELL_H / 2 - 3, pz - 1]) sphere(d = CABLE_D); }
        hull() { translate([SHELL_W / 2 + 26, SHELL_H / 2 - 3, pz - 1]) sphere(d = CABLE_D); translate([DOCK_CLIP_X, DOCK_CLIP_Y + 12, DOCK_T + CABLE_D / 2 + 3]) sphere(d = CABLE_D); }
        hull() { translate([DOCK_CLIP_X, DOCK_CLIP_Y + 12, DOCK_T + CABLE_D / 2 + 3]) sphere(d = CABLE_D); translate([DOCK_CLIP_X, DOCK_CLIP_Y + 4, DOCK_T + CABLE_D / 2]) sphere(d = CABLE_D); }
        hull() { translate([DOCK_CLIP_X, DOCK_CLIP_Y + 4, DOCK_T + CABLE_D / 2]) sphere(d = CABLE_D); translate([DOCK_CLIP_X, -30, DOCK_T + CABLE_D / 2]) sphere(d = CABLE_D); }
    }
}

if (part == "corner_gauge") corner_gauge();
else if (part == "dock_preview") dock_with_charm();
else if (part == "cover") cover();
else if (part == "fit_test") fit_test();
else if (part == "dock") dock();
else if (part == "none") {}
else {
    cover();
    translate([SHELL_W + 15, 0, 0]) fit_test();
    translate([2 * SHELL_W + 45, -20, 0]) dock();
}
