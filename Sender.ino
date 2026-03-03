// LoRa Coverage Mapper — Target
// Arduino + Heltec V3 (Meshtastic)
//
// Listens for "ping" on a private Meshtastic channel.
// Automatically replies with "ACK".
// No node ID needed — private channel means all messages are from the sender.
//
// Wiring:
//   Pin 4  -> Heltec RX
//   Pin 5  -> Heltec TX
//   Pin 13 -> LED (ping received indicator)

#include <HardwareSerial.h>

// Heltec serial
HardwareSerial HeltecSerial(1);
const int HELTEC_RX = 4;
const int HELTEC_TX = 5;

// LED
const int LED_PIN = 13;

void setup() {
  Serial.begin(115200);
  delay(1000);

  HeltecSerial.begin(9600, SERIAL_8N1, HELTEC_RX, HELTEC_TX);

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  Serial.println("Target ready. Listening for ping...");
}

void loop() {
  if (HeltecSerial.available()) {
    String msg = HeltecSerial.readStringUntil('\n');
    msg.trim();

    if (msg.length() == 0) return;

    Serial.println("Received: [" + msg + "]");

    // Skip echo of our own outgoing ACK
    if (msg.indexOf("ACK") >= 0) return;

    // Any message containing "ping" on this private channel is from the sender
    if (msg.indexOf("ping") >= 0) {
      Serial.println("Ping detected! Sending ACK...");

      digitalWrite(LED_PIN, HIGH);
      delay(200);
      digitalWrite(LED_PIN, LOW);

      HeltecSerial.println("ACK");

      Serial.println("ACK sent.");
    }
  }
}