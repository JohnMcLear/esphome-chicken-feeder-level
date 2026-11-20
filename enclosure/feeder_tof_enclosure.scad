// Chicken feeder level sensor enclosure, 6 Nov 2026.
// Holds a LOLIN (Wemos) ESP32-C3 Mini + VL6180X breakout. Mounts on the
// UNDERSIDE of the feeder hopper lid; the sensor looks straight down through
// an open, chamfered window in the floor (no cover: a cover causes ToF crosstalk).
// Print in PETG or ASA. Box: floor down (as printed). Lid: flat side down.
// 4x M3 x 10 self-tappers (or M2.5) hold lid to box; 2 ears screw/zip-tie to
// the feeder lid. USB-C cable enters through the end slot; seal with a dab
// of silicone or a printed TPU grommet.

part = "both";          // "box", "lid", "both"

// ---------- boards (measure + adjust) ----------
c3_l = 34.3;  c3_w = 25.4;  c3_pcb = 1.0;   // LOLIN C3 Mini
c3_stand = 2.0;                              // ledge under the C3 PCB
usb_w = 11.0; usb_h = 6.0;                   // USB-C plug overmold clearance
tof_l = 21.0; tof_w = 18.0; tof_pcb = 1.6;   // VL6180X breakout (generic)
tof_win_x = 0; tof_win_y = 0;                // sensor chip offset from breakout centre
tof_win_d = 7.0;                             // window hole at the sensor
shroud_half_angle = 25;                      // window chamfers out through the floor

// ---------- box ----------
wall = 2.0; floor_t = 3.0; lid_t = 2.0;
gap = 4.0;                                   // space between the boards (wires)
clear = 0.6;                                 // fit clearance around boards
in_l = c3_l + gap + tof_l + 2*clear;
in_w = max(c3_w, tof_w) + 2*clear;
in_h = 12.0;                                 // headers/wires room
boss_d = 7.0; screw_d = 2.6;                 // M3 self-tap pilot
ear_w = 12; ear_len = 10; ear_hole = 4.2;

out_l = in_l + 2*wall; out_w = in_w + 2*wall; out_h = floor_t + in_h;
$fn = 48;

module boss_positions() {
  for (x = [-boss_d/2 + 0.5, out_l + boss_d/2 - 0.5],
       y = [boss_d/2, out_w - boss_d/2]) translate([x, y, 0]) children();
}

module box() {
  difference() {
    union() {
      cube([out_l, out_w, out_h]);
      // external corner bosses for the lid screws
      boss_positions() cylinder(d = boss_d, h = out_h);
    }
    // cavity
    translate([wall, wall, floor_t]) cube([in_l, in_w, in_h + 1]);
    // sensor window, chamfered wider downward so the floor never clips the beam
    translate([tof_cx(), tof_cy(), -0.01])
      cylinder(d1 = tof_win_d + 2*floor_t*tan(shroud_half_angle), d2 = tof_win_d, h = floor_t + 0.02);
    // USB-C slot in the C3 end wall (C3 sits against this wall)
    translate([-1, wall + in_w/2 - usb_w/2,
               floor_t + c3_stand + c3_pcb - 1.0])
      cube([wall + 2, usb_w, usb_h]);
    // screw pilots
    boss_positions() translate([0, 0, 2]) cylinder(d = screw_d, h = out_h);
    // drain/vent pinhole at the far end (lets condensation out)
    translate([out_l - wall - 3, wall + 3, -1]) cylinder(d = 1.5, h = floor_t + 2);
  }
  // C3 ledges (two rails along the long edges of the C3)
  for (y = [wall, wall + in_w - 1.6])
    translate([wall, y, floor_t]) cube([c3_l + clear, 1.6, c3_stand]);
  // sensor locating corners: breakout sits face-down on the floor
  tx0 = wall + c3_l + gap + clear; ty0 = wall + in_w/2 - tof_w/2 - clear;
  for (p = [[tx0 - 1.2, ty0 - 1.2], [tx0 + tof_l + 2*clear, ty0 - 1.2],
            [tx0 - 1.2, ty0 + tof_w + 2*clear], [tx0 + tof_l + 2*clear, ty0 + tof_w + 2*clear]])
    translate([p[0], p[1], floor_t]) cube([1.2, 1.2, tof_pcb + 1.0]);
}

function tof_cx() = wall + c3_l + gap + clear + tof_l/2 + clear + tof_win_x;
function tof_cy() = wall + in_w/2 + tof_win_y;

module lid() {
  difference() {
    union() {
      hull() boss_positions() cylinder(d = boss_d, h = lid_t);
      translate([0, 0, 0]) cube([out_l, out_w, lid_t]);
      // ears on the long sides for fixing to the feeder lid
      for (y = [-ear_len, out_w])
        translate([out_l/2 - ear_w/2, y, 0]) cube([ear_w, ear_len, lid_t + 1]);
      // locating lip that drops inside the box walls (rain/dust)
      translate([wall + 0.3, wall + 0.3, lid_t])
        difference() {
          cube([in_l - 0.6, in_w - 0.6, 2]);
          translate([1.2, 1.2, -1]) cube([in_l - 3, in_w - 3, 4]);
        }
    }
    boss_positions() translate([0, 0, -1]) cylinder(d = 3.4, h = lid_t + 2);
    for (y = [-ear_len/2, out_w + ear_len/2])
      translate([out_l/2, y, -1]) cylinder(d = ear_hole, h = lid_t + 3);
  }
}

if (part == "box")  box();
if (part == "lid")  lid();
if (part == "both") { box(); translate([0, out_w + 25, 0]) lid(); }

// ---------- assembly illustration (not for printing) ----------
module c3_dummy() {
  color("royalblue") cube([c3_l, c3_w, c3_pcb]);
  // USB-C receptacle at the x=0 end, top side
  color("silver") translate([-0.8, c3_w/2 - 4.5, c3_pcb]) cube([7.5, 9, 3.2]);
  color("black") translate([14, c3_w/2 - 2.5, c3_pcb]) cube([5, 5, 0.9]);  // C3 chip
  // pin pads along both long edges
  for (i = [0:7], y = [1.3, c3_w - 1.3])
    color("gold") translate([6 + i*2.54, y, c3_pcb]) cylinder(d = 1.6, h = 0.2, $fn=12);
}
module tof_dummy() {  // face DOWN: chip on the underside, over the window
  color("purple") cube([tof_l, tof_w, tof_pcb]);
  color("black") translate([tof_l/2 + tof_win_x - 2.4, tof_w/2 + tof_win_y - 1.5, -1])
    cube([4.8, 3.0, 1.0]);
  for (i = [0:3]) color("gold")
    translate([3 + i*2.54, tof_w - 2, tof_pcb]) cylinder(d = 1.6, h = 0.2, $fn=12);
}
module assembly() {
  color("lightgrey", 0.45) box();
  translate([wall + clear, wall + clear + (in_w - 2*clear - c3_w)/2, floor_t + c3_stand]) c3_dummy();
  translate([wall + c3_l + gap + 2*clear, wall + in_w/2 - tof_w/2, floor_t + 1.0]) tof_dummy();
  // the 4 wires: 3V3, GND, SDA, SCL
  for (i = [0:3]) color(["red","black","yellow","green"][i])
    hull() {
      translate([wall + 6 + i*2.54, wall + clear + 1.3, floor_t + c3_stand + c3_pcb]) sphere(0.5, $fn=8);
      translate([wall + c3_l + gap + 2*clear + 3 + i*2.54, wall + in_w/2 + tof_w/2 - 2, floor_t + 1 + tof_pcb + 3]) sphere(0.5, $fn=8);
    }
}
if (part == "assembly") assembly();
