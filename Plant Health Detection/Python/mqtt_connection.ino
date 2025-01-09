#include <WiFi.h>
#include <PubSubClient.h>
#include <ESP32Servo.h>
#include <ArduinoJson.h>

// WiFi credentials
const char *ssid = "Realme 2 Pro";
const char *password = "D@hruv234";

// MQTT server details
const char *mqtt_server = "broker.emqx.io"; 
const int mqtt_port = 1883;
const char *mqtt_user = "";  
const char *mqtt_pass = "";  

// MQTT topics
const char* relay_topic = "home/control/relay";
const char* motor_topic = "home/control/motor";
const char* servo_topic = "home/control/servo";
const char* led_topic = "home/control/led";
const char* buzzer_topic = "home/control/buzzer";

// MQTT client setup
WiFiClient espClient;
PubSubClient client(espClient);

// Pin definitions
#define RELAY_PIN 25    
#define MOTOR_PIN_1 15
#define MOTOR_PIN_2 26    
#define LED_PIN 2    
#define BUZZER_PIN 27    
#define SERVO_PIN 32    

Servo myServo;
int servoPosition = 0;  

bool relayState = false;
bool motorState = false;
bool ledState = false;
bool buzzerState = false;

void setup() {
  Serial.begin(115200);

  // Wi-Fi connection
  connectToWiFi();

  // MQTT setup
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(mqttCallback);

  // Pin modes
  pinMode(RELAY_PIN, OUTPUT);
  pinMode(MOTOR_PIN_1, OUTPUT);
  pinMode(MOTOR_PIN_2, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  // Attach Servo
  myServo.attach(SERVO_PIN);

  // Initialize pins to low
  digitalWrite(RELAY_PIN, LOW);
  digitalWrite(MOTOR_PIN_1, LOW);
  digitalWrite(MOTOR_PIN_2, LOW);
  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);
}

void loop() {
  // Check MQTT connection
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  delay(100);  // Shorter delay for responsiveness
}

// Wi-Fi connection function
void connectToWiFi() {
  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("Connected to WiFi");
}

// Reconnect to MQTT
void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    
    // Unique client ID
    String clientId = "ESP32Client_" + String(WiFi.macAddress());
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass)) {
      Serial.println("Connected to MQTT Broker");

      // Subscribe to topics
      client.subscribe(relay_topic);
      client.subscribe(motor_topic);
      client.subscribe(servo_topic);
      client.subscribe(led_topic);
      client.subscribe(buzzer_topic);
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println(" Retrying in 5 seconds...");
      delay(5000);
    }
  }
}

// MQTT callback function
void mqttCallback(char* topic, byte* payload, unsigned int length) {
  char msg[length + 1];
  strncpy(msg, (char*)payload, length);
  msg[length] = '\0';

  // Process topic
  if (strcmp(topic, relay_topic) == 0) {
    relayState = strcmp(msg, "on") == 0;
    digitalWrite(RELAY_PIN, relayState ? HIGH : LOW);
    Serial.println(relayState ? "Relay is ON" : "Relay is OFF");
  } else if (strcmp(topic, motor_topic) == 0) {
    motorState = strcmp(msg, "on") == 0;
    controlMotor(motorState);
    Serial.println(motorState ? "Motor is ON" : "Motor is OFF");
  } else if (strcmp(topic, servo_topic) == 0) {
    servoPosition = strcmp(msg, "on") == 0 ? 90 : 0;
    myServo.write(servoPosition);
    Serial.println(servoPosition == 90 ? "Servo at 90 degrees" : "Servo at 0 degrees");
  } else if (strcmp(topic, led_topic) == 0) {
    ledState = strcmp(msg, "on") == 0;
    digitalWrite(LED_PIN, ledState ? HIGH : LOW);
    Serial.println(ledState ? "LED is ON" : "LED is OFF");
  } else if (strcmp(topic, buzzer_topic) == 0) {
    buzzerState = strcmp(msg, "on") == 0;
    if (buzzerState) {
      notifyBuzzer();
      buzzerState = false;
    }
  }
}

// Motor control function
void controlMotor(bool state) {
  if (state) {
    digitalWrite(MOTOR_PIN_1, HIGH);
    digitalWrite(MOTOR_PIN_2, LOW);
  } else {
    digitalWrite(MOTOR_PIN_1, LOW);
    digitalWrite(MOTOR_PIN_2, LOW);
  }
}

// Buzzer notification
void notifyBuzzer() {
  digitalWrite(BUZZER_PIN, HIGH);
  delay(500);
  digitalWrite(BUZZER_PIN, LOW);
}
