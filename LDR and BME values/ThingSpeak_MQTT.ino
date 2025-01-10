#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <ESP32Servo.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <ThingSpeak.h>
#include <DHT.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
// #include <Adafruit_BME280.h>

#define LED_PIN 2
#define BUZZER_PIN 27
#define MOTOR_PIN 32
#define LDR_PIN 36
#define SEALEVELPRESSURE_HPA (1013.25)
#define DHTTYPE DHT22
#define DHT_PIN 14
#define CHANNEL_ID 856815

Servo servo;
int motorState = LOW;

const char* ssid = "Realme 2 Pro";
const char* password = "D@hruv234";
const char* mqtt_server = "mqtt3.thingspeak.com";
const char* apiKeyWrite = "OGMTFIXRB5E230E8";
const char* apiKeyRead = "8EVVQHCW2NVOYUSD";
const char* topic_led = "channels/856815/subscribe/fields/fields4";

bool LEDstatus = LOW;
bool BUZZstatus = LOW;
bool motorStatus = LOW;
bool servoStatus = LOW;
bool RGBStatus = LOW;
bool relayStatus = LOW;

WiFiClient espClient;
PubSubClient mqttClient(espClient);
AsyncWebServer server(80);

//Adafruit_BME280 bme;
DHT dht(DHT_PIN, DHTTYPE);

// float temperature;
// float humidity ;
// float pressure;
int ldrValue = 0;
float dhtTemp;
float dhtHum;

void connectWiFi() {
  unsigned long startAttemptTime = millis();
  Serial.print("Connecting to WiFi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    if (millis() - startAttemptTime >= 10000) {  
      Serial.println("Failed to connect to WiFi!");
      return;  
    }
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void reconnectMQTT() {
  while (!mqttClient.connected()) {
    String clientId = "JRcWMhICGSErLgEnIQs9KyA";

    if (mqttClient.connect(clientId.c_str(), "JRcWMhICGSErLgEnIQs9KyA", "ftEezZ24Hf1esIM2NtgRyo1e")) {
      Serial.println("MQTT connected");
      mqttClient.subscribe(topic_led);
    } else {
      Serial.print("MQTT connection failed, rc=");
      Serial.print(mqttClient.state());
      Serial.println(" retrying in 5 seconds...");
      delay(5000);
    }
  }
}

void callback(char* topic, byte* message, unsigned int length) {
  String msg;
  for (int i = 0; i < length; i++) {
    msg += (char)message[i];
  }
  Serial.print("Message received on topic: ");
  Serial.println(topic);
  Serial.print("Message: ");
  Serial.println(msg);

  // LED Control
  if (String(topic) == topic_led) {
    if (msg == "ON") {
      digitalWrite(LED_PIN, HIGH);
      Serial.println("LED turned ON");
    } else if (msg == "OFF") {
      digitalWrite(LED_PIN, LOW);
      Serial.println("LED turned OFF");
    }
  }

  // Buzzer Control
  if (msg == "BUZZER_ON") {
    digitalWrite(BUZZER_PIN, HIGH);
    Serial.println("Buzzer turned ON");
  } else if (msg == "BUZZER_OFF") {
    digitalWrite(BUZZER_PIN, LOW);
    Serial.println("Buzzer turned OFF");
  }

  if (msg == "MOTOR_ON" && motorState == LOW) {
    //digitalWrite(MOTOR_PIN, HIGH);
    motorState = HIGH;
    Serial.println("Motor turned ON");
  } else if (msg == "MOTOR_OFF" && motorState == HIGH) {
    motorState = LOW;
    //digitalWrite(MOTOR_PIN, LOW);
    Serial.println("Motor turned OFF");
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(MOTOR_PIN, OUTPUT);
  pinMode(LDR_PIN, INPUT);
  servo.attach(MOTOR_PIN);

  connectWiFi();

  // if (!bme.begin()) {
  //   Serial.println("Could not find a valid BME280 sensor, check wiring!");
  //   while (0);
  // }

  dht.begin();

  mqttClient.setServer(mqtt_server, 1883);
  mqttClient.setCallback(callback);

  ThingSpeak.begin(espClient);

  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
  String htmlContent = "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><title>ESP32 Control</title>";
htmlContent += "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css' rel='stylesheet'>";
htmlContent += "<script src='https://cdn.plot.ly/plotly-latest.min.js'></script>";
htmlContent += "<style>body { background-color: #f8f9fa; } #chart { max-width: 100%; max-height: 700px; margin: 200; margin-bottom: 20px; } h1 { text-align: center; margin-top: 20px; }</style>";
htmlContent += "</head><body>";

htmlContent += "<h1>Data Visualization</h1>";
htmlContent += "<div class='container'><div id='chart'></div></div>";

htmlContent += "<script>";
htmlContent += "let timeLabels = Array.from({ length: 10 }, (_, i) => i + 1);";
htmlContent += "let weatherData = {";
htmlContent += "  ldr: Array(10).fill(0),";
htmlContent += "  temperature: Array(10).fill(0),";
htmlContent += "  humidity: Array(10).fill(0),";
htmlContent += "};";

htmlContent += "let layout = {";
htmlContent += "  title: 'Sensor Data Over Time',";
htmlContent += "  xaxis: { title: 'Time', showgrid: true },";
htmlContent += "  yaxis: { title: 'Sensor Value', showgrid: true },";
htmlContent += "  showlegend: true";
htmlContent += "};";

htmlContent += "let traceLDR = {";
htmlContent += "  x: [], y: [], type: 'scatter', mode: 'lines', name: 'LDR Sensor', line: { color: 'blue' }";
htmlContent += "};";

htmlContent += "let traceTemp = {";
htmlContent += "  x: [], y: [], type: 'scatter', mode: 'lines', name: 'DHT Temp (°C)', line: { color: 'red' }";
htmlContent += "};";

htmlContent += "let traceHum = {";
htmlContent += "  x: [], y: [], type: 'scatter', mode: 'lines', name: 'DHT Humidity (%)', line: { color: 'green' }";
htmlContent += "};";

htmlContent += "let data = [traceLDR, traceTemp, traceHum];";

htmlContent += "function updateData() {";
htmlContent += "  var xhr = new XMLHttpRequest();";
htmlContent += "  xhr.open('GET', '/get_sensor_data', true);";
htmlContent += "  xhr.onreadystatechange = function() {";
htmlContent += "    if (xhr.readyState == 4 && xhr.status == 200) {";
htmlContent += "      var response = JSON.parse(xhr.responseText);";
htmlContent += "      var ldr = response.ldr;";
htmlContent += "      var dhtTemp = response.dhtTemp;";
htmlContent += "      var dhtHum = response.dhtHum;";

htmlContent += "      let currentTime = new Date().toLocaleTimeString();";
htmlContent += "      timeLabels.push(currentTime);";
htmlContent += "      traceLDR.x.push(currentTime); traceLDR.y.push(ldr);";
htmlContent += "      traceTemp.x.push(currentTime); traceTemp.y.push(dhtTemp);";
htmlContent += "      traceHum.x.push(currentTime); traceHum.y.push(dhtHum);";

htmlContent += "      if (traceLDR.x.length > 50) { traceLDR.x.shift(); traceLDR.y.shift(); }";
htmlContent += "      if (traceTemp.x.length > 50) { traceTemp.x.shift(); traceTemp.y.shift(); }";
htmlContent += "      if (traceHum.x.length > 50) { traceHum.x.shift(); traceHum.y.shift(); }";

htmlContent += "      Plotly.update('chart', data);";
htmlContent += "    }";
htmlContent += "  };";
htmlContent += "  xhr.send();";
htmlContent += "}";

htmlContent += "function drawChart() {";
htmlContent += "  const data = [";
htmlContent += "    { x: timeLabels, y: weatherData.ldr, type: 'bar3d', mode: 'lines', name: 'LDR Sensor', line: { color: 'blue' } },";
htmlContent += "    { x: timeLabels, y: weatherData.temperature, type: 'bar3d', mode: 'lines', name: 'DHT Temp (°C)', line: { color: 'red' } },";
htmlContent += "    { x: timeLabels, y: weatherData.humidity, type: 'bar3d', mode: 'lines', name: 'DHT Humidity (%)', line: { color: 'green' } }";
htmlContent += "  ];";

htmlContent += "  const layout = {";
htmlContent += "    title: 'Sensor Data Over Time',";
htmlContent += "    xaxis: { title: 'Time', showgrid: true },";
htmlContent += "    yaxis: { title: 'Sensor Value', showgrid: true },";
htmlContent += "    showlegend: true";
htmlContent += "  };";

htmlContent += "  Plotly.newPlot('chart', data, layout);";
htmlContent += "}";

htmlContent += "function updateGraph() {";
htmlContent += "  updateData();";  
htmlContent += "}";

htmlContent += "drawChart();";

htmlContent += "function controlDevice(device, action) {";
htmlContent += "  fetch('/control?device=' + device + '&action=' + action);";
htmlContent += "    .then(response => response.text())";
htmlContent += "    .then(data => { console.log('Action completed:', data); });";
htmlContent += "}";

htmlContent += "</script>";

htmlContent += "<h2>Control ESP32 Devices & Sensor Data</h2>";

// LED Control (Toggle Switch)
htmlContent += "<p>LED Status: <span id='led-status'>OFF</span></p>";
htmlContent += "<label class='switch'><input type='checkbox' id='led-toggle' " + String(LEDstatus ? "checked" : "") + " onchange='controlDevice(\"LED\", this.checked ? \"ON\" : \"OFF\")'><span class='slider'></span></label>";

// Buzzer Control (Toggle Switch)
htmlContent += "<p>Buzzer Status: <span id='buzzer-status'>OFF</span></p>";
htmlContent += "<label class='switch'><input type='checkbox' id='buzzer-toggle' " + String(BUZZstatus ? "checked" : "") + " onchange='controlDevice(\"BUZZER\", this.checked ? \"ON\" : \"OFF\")'><span class='slider'></span></label>";

// RGB Control (Toggle Switch)
htmlContent += "<p>RGB Status: <span id='rgb-status'>OFF</span></p>";
htmlContent += "<label class='switch'><input type='checkbox' id='rgb-toggle' " + String(RGBStatus ? "checked" : "") + " onchange='controlDevice(\"RGB\", this.checked ? \"ON\" : \"OFF\")'><span class='slider'></span></label>";

// Relay Control (Toggle Switch)
htmlContent += "<p>Relay Status: <span id='relay-status'>OFF</span></p>";
htmlContent += "<label class='switch'><input type='checkbox' id='relay-toggle' " + String(relayStatus ? "checked" : "") + " onchange='controlDevice(\"RELAY\", this.checked ? \"ON\" : \"OFF\")'><span class='slider'></span></label>";

// Motor Control (Toggle Switch)
htmlContent += "<p>Motor Status: <span id='motor-status'>OFF</span></p>";
htmlContent += "<label class='switch'><input type='checkbox' id='motor-toggle' " + String(motorStatus ? "checked" : "") + " onchange='controlDevice(\"MOTOR\", this.checked ? \"ON\" : \"OFF\")'><span class='slider'></span></label>";

// Servo Control (Toggle Switch)
htmlContent += "<p>Servo Status: <span id='servo-status'>OFF</span></p>";
htmlContent += "<label class='switch'><input type='checkbox' id='servo-toggle' " + String(servoStatus ? "checked" : "") + " onchange='controlDevice(\"SERVO\", this.checked ? \"ON\" : \"OFF\")'><span class='slider'></span></label>";


htmlContent += "<br><br>";
htmlContent += "<h2>Control Servo</h2>";
htmlContent += "<input type='number' id='servoAngle' min='0' max='180' value='90' />";
htmlContent += "<button onclick='controlServo()'>Set Servo Angle</button><br><br>";

htmlContent += "<button onclick='updateGraph()'>Update Graph</button>"; 

htmlContent += "</body></html>";

  request->send(200, "text/html", htmlContent);
});

  server.on("/get_sensor_data", HTTP_GET, [](AsyncWebServerRequest *request) {
    float dhtTemp = dht.readTemperature();
    float dhtHum = dht.readHumidity();
    int ldrValue = analogRead(LDR_PIN);

    String jsonResponse = "{";
    jsonResponse += "\"ldr\": " + String(ldrValue) + ",";
    jsonResponse += "\"dhtTemp\": " + String(dhtTemp) + ",";
    jsonResponse += "\"dhtHum\": " + String(dhtHum);
    jsonResponse += "}";

    request->send(200, "application/json", jsonResponse);
  });

  server.on("/control_led", HTTP_GET, [](AsyncWebServerRequest *request) {
    String state = request->getParam("state")->value();
    if (state == "ON") {
      digitalWrite(LED_PIN, HIGH);
      LEDstatus = true;
    } else if(state == "OFF") {
      digitalWrite(LED_PIN, LOW);
      LEDstatus = false;
    }
    request->send(200, "text/plain", "LED " + state);
  });

  server.on("/control_buzzer", HTTP_GET, [](AsyncWebServerRequest *request) {
    String state = request->getParam("state")->value();
    if (state == "ON") {
      digitalWrite(BUZZER_PIN, HIGH);
      BUZZstatus = true;
    } else if (state == "OFF"){
      digitalWrite(BUZZER_PIN, LOW);
      BUZZstatus = false;
    }
    request->send(200, "text/plain", "Buzzer " + state);
  });

  server.on("/control_motor", HTTP_GET, [](AsyncWebServerRequest *request) {
    String state = request->getParam("state")->value();
    if (state == "ON") {
      motorState = HIGH;
      digitalWrite(MOTOR_PIN, HIGH);
      motorStatus = true;
    } else if(state == "OFF") {
      motorState = LOW;
      digitalWrite(MOTOR_PIN, LOW);
      motorStatus = false;
    }
    request->send(200, "text/plain", "Motor " + state);
  });

  server.on("/control_servo", HTTP_GET, [](AsyncWebServerRequest *request) {
    String angle = request->getParam("angle")->value();
    servo.write(angle.toInt());
    servoStatus = true;
    request->send(200, "text/plain", "Servo set to " + angle);
  });

  server.begin();
}

void loop() {
  unsigned long lastReconnectAttempt = 0;
  unsigned long reconnectInterval = 60000;
  unsigned long currentMillis = millis();

  if (!mqttClient.connected() && currentMillis - lastReconnectAttempt >= reconnectInterval) {
    reconnectMQTT();
    lastReconnectAttempt = currentMillis;
  }
  // temperature = bme.readTemperature();
  // humidity = bme.readHumidity();
  // pressure = bme.readPressure() / 100.0F;

  dhtTemp = dht.readTemperature();
  dhtHum = dht.readHumidity();
  if (isnan(dhtTemp) || isnan(dhtHum)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  ldrValue = analogRead(LDR_PIN);

  ThingSpeak.setField(1, dhtTemp);
  ThingSpeak.setField(2, dhtHum);
  // ThingSpeak.setField(3, temperature);
  // ThingSpeak.setField(4, humidity);
  // ThingSpeak.setField(5, pressure);
  ThingSpeak.setField(6, ldrValue);

  long response = ThingSpeak.writeFields(CHANNEL_ID, apiKeyWrite);
  if (response == 200) {
    Serial.println("Data uploaded successfully!");
  } else {
    Serial.print("Error uploading data. Response code: ");
    Serial.println(response);
  }
  lastReconnectAttempt = currentMillis;
  mqttClient.loop();

}
