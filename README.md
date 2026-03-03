# LoRa Coverage Mapper

A LoRa/Meshtastic coverage mapping tool that plots signal success and failure on a real map in real time between two nodes. Built using an Arduino Nano ESP32, a Heltec LoRa V3 running Meshtastic firmware, an Ultimae GPS module, and a Processing sketch running on laptop.

---

## How It Works

When a button is pressed on a portable sender unit a `ping` message is sent over a private Meshtastic channel to a fixed target node. The target node automatically replies with `ACK`. Based on whether the ACK is received within a timeout window, the result is logged as **Direct** (green) or **Failed** (red) alongside the current GPS coordinates. The Processing sketch plots these results as red (failed) or green (success) dots on a map image in real time.

```
[Button Press]
      |
      v
[Heltec V3 Sender] --LoRa Meshtastic--> [Heltec V3 Target]
      |                                         |
  UART Serial                              UART Serial
      |                                         |
[Arduino Nano ESP32]                    [Arduino (Target)]
      |
  USB Serial
      |
[Processing Sketch]
      |
  Map with dots
```

---

## Hardware Required

### Sender Unit
- Arduino Nano ESP32
- Heltec LoRa V3 (running Meshtastic firmware)
- Ultimate GPS module 
- 1x Push button (ping)
- 2x LEDs (GPS fix indicator — green/red)
- 1x LED (status — waiting for ACK)
- Resistors (220–330Ω for each LED)
- Laptop running Processing 4


### Target Unit
- Arduino Nano ESP32
- Heltec LoRa V3 (running Meshtastic firmware)
- 1x LED (ping received indicator)


## Wiring

### Sender — Arduino Nano ESP32

| Arduino Pin | Function          |
|-------------|-------------------|
| 5           | Heltec TX         |
| 7           | Heltec RX         |
| 8           | Ping button       |
| 18          | LED — GPS fix     |
| 19          | LED — No GPS fix  |
| 20          | LED — Status      |
| 21          | GPS RX            |
| 22          | GPS TX            |

### Target — Arduino

| Arduino Pin | Function          |
|-------------|-------------------|
| 4           | Heltec RX         |
| 5           | Heltec TX         |
| 13          | LED — Ping received |

All buttons wired between pin and GND (INPUT_PULLUP used in code).
All LEDs wired with a 220–330Ω resistor between pin and GND.

---

## Meshtastic Configuration

Both Heltec V3 boards must be running Meshtastic firmware and configured as follows:

### Both Nodes
- **Channel 0** renamed to a private channel name known only to your two nodes
- Both nodes must share the same channel name and PSK (pre-shared key)

### Serial Module (both nodes)
- **Enabled:** Yes
- **Mode:** Text Message
- **Echo:** Off
- **RX pin:** 6
- **TX pin:** 7

---

## Software Setup

### Arduino
1. Install the following libraries via Arduino Library Manager:
   - `TinyGPSPlus`
2. Upload `sender/sender.ino` to the Arduino Nano ESP32
3. Upload `target/target.ino` to the target Arduino

### Processing
1. Download and install [Processing 4](https://processing.org/)
2. Place your map image as `map.png` inside the sketch's `data/` folder
3. Update the map boundary coordinates in the sketch to match your map:
```java
float latMin = 53.377366;
float latMax = 53.389229;
float lonMin = -2.949590;
float lonMax = -2.916461;
```
4. Update the serial port index if needed:
```java
myPort = new Serial(this, Serial.list()[3], 115200);
```
5. Run the sketch

---

## Map Image

The map image should be a flat projection (e.g. exported from Google Maps, OpenStreetMap, or similar) with known boundary coordinates. The four boundary values (latMin, latMax, lonMin, lonMax) must correspond exactly to the edges of your image.

A good free tool for exporting map images with known coordinates is [JOSM](https://josm.openstreetmap.de/) or the [Overpass Turbo](https://overpass-turbo.eu/) export feature.

---

## CSV Output Format

The Arduino outputs one line per ping attempt over USB serial:

```
Timestamp(ms),Result,Latitude,Longitude
1102460,Direct,53.383100,-2.930200
1103641,Failed,GPS_NOT_FIXED,GPS_NOT_FIXED
```

- `Direct` — ACK received from target within timeout
- `Failed` — No ACK received within 15 seconds, or no GPS fix

---

## Processing Sketch Controls

| Key | Action |
|-----|--------|
| Spacebar | Add a random test dot (Direct or Failed) |

---



## Future Improvements

- [ ] Proto mode serial parsing for hop count detection
- [ ] Save/load dot data to CSV file from Processing as when the sketch is closed we lose all data
- [ ] Variable dot size based on RSSI
- [ ] Make more portable by building on RPi
- [ ] Think about 3D design to make arial position consistant on Sender
- [ ] There could be two setting for mapping here. Node to node and node to mesh
- [ ] ditch the button and make it send a ping every 30 secs
- [ ] Have an LED that lights red for Fail or Green for Success.
- [ ] Hop detection is not currently visible. The system detects Direct vs Failed only. Hopped detection would require switching the Meshtastic serial module to Proto mode and parsing protobuf packets on the Arduino.

---

