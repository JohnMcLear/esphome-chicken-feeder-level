# Chicken feeder level sensor (ESPHome + Home Assistant)

Tells you when the chicken feeder is running low or empty. It's rough but it works: it has run on a real flock since November 2026. Released as-is in the hope that others will refine it.

![Parts](images/parts.png)

## How it works

- A **VL6180X time-of-flight sensor** mounts under the hopper lid and looks straight down at the feed.
- A **LOLIN ESP32-C3 Mini** running ESPHome reports the distance to Home Assistant.
- An HA package judges the level only at **quiet times** (17:30 and 06:30/08:00), when the birds aren't working the treadle flap, and sends a LOW or EMPTY alert.

## Hardware

| Part | Notes |
|---|---|
| LOLIN (Wemos) ESP32-C3 Mini | Wi-Fi TX is set to 8.5 dB because some v2.1 boards won't associate at full power |
| VL6180X breakout | I²C: SDA GPIO8, SCL GPIO10, 3V3, GND |
| Printed enclosure | `enclosure/` (OpenSCAD source + STLs). PETG or ASA. It screws or zip-ties to the underside of the hopper lid. The sensor window is open on purpose, because a cover causes ToF crosstalk |
| 2 A USB supply | A weak supply caused brownouts and offline periods |

Tested on a treadle feeder with a 9 kg hopper. Any covered hopper should work.

## Lessons learned (read these before calibrating)

- **Daytime readings are noise.** Birds lift the treadle flap, and the sensor then sees spikes of ~120–175 mm. The firmware runs a 3-minute median (36 × 5 s samples), but only the quiet-time readings are reliable.
- **Empty is closer than you'd think.** Feed cones and slumps, so an empty hopper read ~48–50 mm at quiet times rather than the full depth. Our first threshold (≥70 mm) never fired when the feeder really ran out.
- Our numbers: **full ≈ 16–27 mm, low ≥ 40 mm, empty ≥ 46 mm.** Measure your own: log a full night after a refill, and a night when it's actually empty.
- "No Target" / "Out of Range" is treated as empty. If the box falls off the lid, the sensor sees the ground and gives a false "empty".
- A metal (galvanised) feeder cage blocks Wi-Fi. Keep the ESP outside the cage, or use an external-antenna board.

## Install

1. `esphome/`: copy `secrets.example.yaml` to `secrets.yaml` and fill it in. Set `FULL_MM` / `EMPTY_MM`, then flash.
2. `home-assistant/chicken_feeder.yaml`: drop it into your `packages/` folder. Replace `notify.YOUR_NOTIFIER` with your notify entity, and adjust the 40/46 mm thresholds and entity IDs if your device name differs.

The VL6180X component is [thedayowl/esphome-vl6180x](https://github.com/thedayowl/esphome-vl6180x), pinned to a reviewed commit.

## TODO / future version

- [ ] **Beeper/buzzer** at the feeder for a local low-feed warning
- [ ] Move the empty/low logic onto the device (quiet-time windows) so it works without HA
- [ ] Auto-calibration (learn full/empty from the readings after a refill)
- [ ] Enclosure v2: proper mounting ears, a cable gland, and an external-antenna option for metal cages
- [ ] Better handling of feed cone/slump, perhaps a wider-angle or multi-zone ToF sensor (e.g. VL53L5CX)

## License

MIT. Use it, fork it, improve it.
