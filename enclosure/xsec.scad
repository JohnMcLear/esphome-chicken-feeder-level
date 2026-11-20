include <feeder_tof_enclosure.scad>
// cut through the middle (long axis), lid fitted on top
intersection() {
  union() {
    assembly();
    color("steelblue", 0.8) translate([0, out_w, out_h + lid_t]) mirror([0,0,1]) mirror([0,1,0]) lid();
  }
  translate([-20, -20, -20]) cube([200, wall + in_w/2 + 20, 100]);
}
