from flask import Flask, jsonify, render_template
from flask_cors import CORS
import logging
import random
import time
import paho.mqtt.client as mqtt
import json
import socket

app = Flask(__name__)
CORS(app)

log = logging.basicConfig(level=logging.INFO)

MQTT_BROKER = "test.mosquitto.org"  # Change this to the broker address (e.g., "test.mosquitto.org" for public broker)
MQTT_PORT = 8885 
MQTT_TOPIC = "sensor_data"

mqtt_client = mqtt.Client()
connetcted_to_mqtt = False

def is_mqtt_broker_reachable():
    try:
        socket.create_connection((MQTT_BROKER, MQTT_PORT), timeout=2)
        return True
    except OSError:
        return False

def connect_mqtt():
    global connected_to_mqtt
    if is_mqtt_broker_reachable():
        try:
            mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
            connected_to_mqtt = True
            logging.info(f"Connected to MQTT broker at {MQTT_BROKER}:{MQTT_PORT}")
        except Exception as e:
            logging.error(f"Failed to connect to MQTT broker: {e}")
    else:
        connected_to_mqtt = False
        logging.warning(f"MQTT broker at {MQTT_BROKER}:{MQTT_PORT} is not reachable.")

def publish_sensor_data():
    data = {
        "temperature": round(random.uniform(-40, 50), 2),
        "humidity": round(random.uniform(0, 100), 2),
        "pressure": round(random.uniform(900, 1050), 2),
	"wind speed" : round(random.uniform(0,100),2),
	"precipitation" : round(random.uniform(0,500),2),
	"visibility" : round(random.uniform(0,20), 2),
	"cloud cover" : round(random.uniform(0,100), 2),
	"dev point" : round(random.uniform(-40,35),2),
    }
    payload = json.dumps(data)
    try:
        mqtt_client.publish(MQTT_TOPIC, payload)
        logging.info(f"Published data to MQTT: {payload}")
    except Exception as e:
        logging.error(f"Failed to publish data to MQTT: {e}")

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/message")
def message():
    return jsonify({'message': 'Hello from server'})

@app.route("/data", methods=['GET'])
def data():
    data = {
        "temperature": round(random.uniform(-40, 50), 2),
        "humidity": round(random.uniform(0, 100), 2),
        "pressure": round(random.uniform(900, 1050), 2),
	"wind speed" : round(random.uniform(0,100)),
	"precipitation" : round(random.uniform(0,500)),
	"visibility" : round(random.uniform(0,100)),
	"cloud cover" : round(random.uniform(0,100)),
	"dew point" : round(random.uniform(-40,35)),
    }
    return jsonify(data)

if __name__ == "__main__":
    connect_mqtt()
    app.run(debug=True, host="0.0.0.0", port=8000)
    while True:
        publish_sensor_data()
        time.sleep(2)