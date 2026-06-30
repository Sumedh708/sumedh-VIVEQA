#include <WiFi.h>
#include <Firebase_ESP_Client.h>

// Provide the token generation process info.
#include "addons/TokenHelper.h"
// Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// --- WI-FI CREDENTIALS ---
#define WIFI_SSID "Anonymous"
#define WIFI_PASSWORD "sumesat123"

// --- FIREBASE CREDENTIALS ---
#define API_KEY "AIzaSyCekMC-pHddlec5uBnKej-PD1AmoZgGVbY"
#define DATABASE_URL "https://fpgavehiclestabilizer-default-rtdb.firebaseio.com/" 

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool signupOK = false;

// Hardware UART Pins for FPGA Interface
#define RX_PIN 16 
#define TX_PIN 17 

void setup() {
  Serial.begin(115200); // Debug to Laptop
  Serial1.begin(115200, SERIAL_8N1, RX_PIN, TX_PIN); // Listen to FPGA

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println("\nConnected to Wi-Fi!");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase Auth Successful");
    signupOK = true;
  } else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  config.token_status_callback = tokenStatusCallback;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // Check for incoming commands from the FPGA
  if (Serial1.available()) {
    String incomingMessage = Serial1.readStringUntil('\n');
    incomingMessage.trim(); // Clean up formatting/whitespaces

    if (Firebase.ready() && signupOK) {
      
      // 1. State 2 Warning: Major Fluctuation Detected
      if (incomingMessage == "WARN") {
        Serial.println("Warning Received: Updating likely_crashed...");
        if (Firebase.RTDB.setBool(&fbdo, "/sensor/likely_crashed", true)) {
          Serial.println("Firebase updated: /sensor/likely_crashed = true");
        } else {
          Serial.println("Failed to update Firebase: " + fbdo.errorReason());
        }
      }
      
      // 2. State 3 Critical: Continuous Roll/Flip Verified
      else if (incomingMessage == "SOS") {
        Serial.println("Critical Alarm Received: Updating sos...");
        if (Firebase.RTDB.setBool(&fbdo, "/sensor/sos", true)) {
          Serial.println("Firebase updated: /sensor/sos = true");
        } else {
          Serial.println("Failed to update Firebase: " + fbdo.errorReason());
        }
      }
      
      // 3. System Reset: Keypad '0' Pressed
      else if (incomingMessage == "RESET") {
        Serial.println("Reset Received: Clearing sensor states...");
        
        // Using a JSON object to clear both keys simultaneously in one network call
        FirebaseJson json;
        json.set("likely_crashed", false);
        json.set("sos", false);
        
        if (Firebase.RTDB.updateNode(&fbdo, "/sensor", &json)) {
          Serial.println("Firebase paths reset smoothly.");
        } else {
          Serial.println("Failed to clear Firebase nodes: " + fbdo.errorReason());
        }
      }
    }
  }
}
