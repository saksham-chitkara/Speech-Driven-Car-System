#include <WiFi.h>
#include <WebServer.h>

// Replace with your Wi-Fi credentials
const char* ssid = "Aryan";
const char* password = "w864wsx5";

// WiFiServer server(6000);  // Create a server on port 6000
WebServer server(80);
// Define motor control pins for L298N
// Motor A
const int motorEnablePinA = 19; // ENA for Motor A speed control (PWM)
const int motorIn1A = 17; // IN1 for Motor A direction
const int motorIn2A = 5;  // IN2 for Motor A direction

// Motor B
const int motorEnablePinB = 21; // ENB for Motor B speed control (PWM)
const int motorIn3B = 16; // IN3 for Motor B direction
const int motorIn4B = 4;  // IN4 for Motor B direction ..... may be disabled

void setup() {
  Serial.begin(115200);

  // Setup motor control pins as outputs
  pinMode(motorEnablePinA, OUTPUT);
  pinMode(motorIn1A, OUTPUT);
  pinMode(motorIn2A, OUTPUT);

  pinMode(motorEnablePinB, OUTPUT);
  pinMode(motorIn3B, OUTPUT);
  pinMode(motorIn4B, OUTPUT);

  // Ensure motors are initially stopped
  digitalWrite(motorIn1A, LOW);
  digitalWrite(motorIn2A, LOW);
  digitalWrite(motorIn3B, LOW);
  digitalWrite(motorIn4B, LOW);

  analogWrite(motorEnablePinA, 0);  // Set Motor A speed to 0
  analogWrite(motorEnablePinB, 0);  // Set Motor B speed to 0

  // Connect to Wi-Fi network
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  
  Serial.println("");
  Serial.println("WiFi connected.");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  server.on("/send", HTTP_POST, []() {
    String data = server.arg("plain");
    data.trim();
    data.toUpperCase();
    // Handle commands based on received data
    String code = "-1";
    if (data == "FORWARD") {
      code = "1"; 
      handleForward();
    } else if (data == "STOP") {
      code = "0";
      handleStop();
    } else if (data == "REVERSE") {
      code = "2";
      handleBack();
    } else if (data == "RIGHT") {
      code = "4";
      handleRight();
    } else if (data == "LEFT") {
      code = "3";
      handleLeft();
    } else {
      Serial.println("Unknown command: " + data);
    }

    server.send(200, "text/plain", "Code: " + code);
  });

  server.begin();  // Start the server
}

void loop() {          
  server.handleClient();
  //         // DC Motor control based on received commands
  //         if (currentLine == "forward") {
  //           // Motor A and B move forward
            
  //         } else if (currentLine == "reverse") {
  //           // Motor A and B move reverse
            
  //         } else if (currentLine == "stop") {
  //           // Stop both motors
            
  //         } else {
  //           Serial.println("Unknown command.");
  //         }

  //         currentLine = "";  // Clear the current line for the next message
  //       } else {
  //         currentLine += c;  // Accumulate characters to form a line
  //       }
  //     }
  //   }
  //   client.stop();  // Close the connection
  //   Serial.println("Client disconnected.");
  // }
}

void handleForward() {
  digitalWrite(motorIn1A, LOW);  // Motor A forward
  digitalWrite(motorIn2A, HIGH);
  analogWrite(motorEnablePinA, 150);  // Set speed for Motor A

  digitalWrite(motorIn3B, HIGH);  // Motor B forward
  digitalWrite(motorIn4B, LOW);
  analogWrite(motorEnablePinB, 150);  // Set speed for Motor B
  
  Serial.println("Both motors moving forward.");
}

void handleBack() {
  digitalWrite(motorIn1A, HIGH);   // Motor A reverse
  digitalWrite(motorIn2A, LOW);
  analogWrite(motorEnablePinA, 150);  // Set speed for Motor A

  digitalWrite(motorIn3B, LOW);   // Motor B reverse
  digitalWrite(motorIn4B, HIGH);
  analogWrite(motorEnablePinB, 150);  // Set speed for Motor B
  
  Serial.println("Both motors moving reverse.");
}

void handleLeft() {
  digitalWrite(motorIn1A, LOW);   // Motor A reverse
  digitalWrite(motorIn2A, HIGH);
  analogWrite(motorEnablePinA, 200);  // Set speed for Motor A

  digitalWrite(motorIn3B, LOW);   // Motor B reverse
  digitalWrite(motorIn4B, LOW);
  analogWrite(motorEnablePinB, 0);  // Set speed for Motor B
  delay(1000);

  handleStop();
}

void handleRight() {
  digitalWrite(motorIn1A, LOW);   // Motor A reverse
  digitalWrite(motorIn2A, LOW);
  analogWrite(motorEnablePinA, 0);  // Set speed for Motor A

  digitalWrite(motorIn3B, HIGH);   // Motor B reverse
  digitalWrite(motorIn4B, LOW);
  analogWrite(motorEnablePinB, 200);  // Set speed for Motor B
  delay(1000);

  handleStop();
}

void handleStop() {
  digitalWrite(motorIn1A, LOW);   
  digitalWrite(motorIn2A, LOW);
  analogWrite(motorEnablePinA, 0);  // Disable Motor A

  digitalWrite(motorIn3B, LOW);   
  digitalWrite(motorIn4B, LOW);
  analogWrite(motorEnablePinB, 0);  // Disable Motor B
  
  Serial.println("Both motors stopped.");
}