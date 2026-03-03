import processing.serial.*;
import java.util.ArrayList;

// Serial port
Serial myPort;

// Map image
PImage mapImg;

// Map boundaries
float latMin = 53.377366;
float latMax = 53.389229;
float lonMin = -2.949590;
float lonMax = -2.916461;

// Debug panel
ArrayList<String> debugLines = new ArrayList<String>();
int maxLines = 20;
int panelX   = 800;
int panelWidth = 200;

// Stored plot points
ArrayList<Float>   dotX     = new ArrayList<Float>();
ArrayList<Float>   dotY     = new ArrayList<Float>();
ArrayList<Integer> dotColor = new ArrayList<Integer>();

void setup() {
  size(1000, 600);

  mapImg = loadImage("map.png");
  panelX = mapImg.width;
  println("Map size: " + mapImg.width + " x " + mapImg.height);
  surface.setSize(mapImg.width + panelWidth, mapImg.height);

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[3], 115200);
  myPort.bufferUntil('\n');

  textFont(createFont("Arial", 12));
}

void draw() {
  // Draw map
  image(mapImg, 0, 0);

  // Redraw all stored dots
  noStroke();
  for (int i = 0; i < dotX.size(); i++) {
    fill(dotColor.get(i));
    ellipse(dotX.get(i), dotY.get(i), 8, 8);
  }

  // Draw debug panel
  fill(0, 150);
  rect(panelX, 0, panelWidth, height);
  fill(255);
  textSize(12);
  for (int i = 0; i < debugLines.size(); i++) {
    text(debugLines.get(i), panelX + 10, 20 + i * 15);
  }
}

void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line != null) {
    line = line.trim().replace("\r", "").replace("\n", "");

    String[] parts = split(line, ',');

    if (parts.length == 4) {
      String result = parts[1];
      String rawLat = parts[2];
      String rawLon = parts[3];

      // No GPS fix — show in panel but don't plot
      if (rawLat.equals("GPS_NOT_FIXED") || rawLon.equals("GPS_NOT_FIXED")) {
        debugLines.add(">> " + result + " (no fix)");
        if (debugLines.size() > maxLines) debugLines.remove(0);
        return;
      }

      float lat = float(rawLat);
      float lon = float(rawLon);

      // Add to debug panel
      debugLines.add(result + " " + nf(lat, 1, 4) + ", " + nf(lon, 1, 4));
      if (debugLines.size() > maxLines) debugLines.remove(0);

      // Map coordinates to screen
      float x = map(lon, lonMin, lonMax, 0, panelX);
      float y = map(lat, latMax, latMin, 0, height);

      // Green = Direct (ACK), Red = Failed
      int c;
      if (result.equals("Direct"))      c = color(0, 255, 0);
      else if (result.equals("Failed")) c = color(255, 0, 0);
      else                              c = color(255);

      dotX.add(x);
      dotY.add(y);
      dotColor.add(c);

    } else {
      debugLines.add("? " + line);
      if (debugLines.size() > maxLines) debugLines.remove(0);
    }
  }
}

// Spacebar adds a test dot
void keyPressed() {
  if (key == ' ') {
    String[] types = {"Direct", "Failed"};
    String result = types[(int)random(2)];
    float randLat = random(latMin, latMax);
    float randLon = random(lonMin, lonMax);
    float x = map(randLon, lonMin, lonMax, 0, panelX);
    float y = map(randLat, latMax, latMin, 0, height);

    int c = result.equals("Direct") ? color(0, 255, 0) : color(255, 0, 0);

    dotX.add(x);
    dotY.add(y);
    dotColor.add(c);

    debugLines.add("TEST " + result + " " + nf(randLat, 1, 4) + ", " + nf(randLon, 1, 4));
    if (debugLines.size() > maxLines) debugLines.remove(0);
  }
}
