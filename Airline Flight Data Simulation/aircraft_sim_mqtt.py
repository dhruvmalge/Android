from flask import Flask, render_template, jsonify
import flask_cors as cors
import logging
import numpy
import paho.mqtt.client as mqtt
import random
import time
import json
import socket

mqtt_broker = "test.mosquitto.org"
mqtt_port = 1883
mqtt_topic = "flight/airport_simulation"
flask = Flask(__name__)
cors.CORS(flask)

log = logging.basicConfig(level = logging.INFO)

mqtt_client = mqtt.Client()
connected_to_mqtt = False

def is_mqtt_broker_reachable():
    try:
        socket.create_connection((mqtt_broker, mqtt_port), timeout=2)
        return True
    except OSError:
        return False

def connect_to_mqtt():
    global connected_to_mqtt
    if is_mqtt_broker_reachable():
        try:
            mqtt_client.connect(mqtt_broker, mqtt_port, 60)
            connected_to_mqtt = True
            logging.INFO(f"Connected to MQTT {mqtt_broker} at {mqtt_port}")
        except:
            logging.error(f"Failed to connect MQTT at {mqtt_broker}")
    else:
        connected_to_mqtt = False
        logging.warning(f"MQTT broker not reachable on {mqtt_broker} with port {mqtt_port}")

def publish_data():
   data = {}
   payload = json.dumps(data)
   try:
       mqtt_client.publish(mqtt_broker, payload)
       logging.INFO(f"Published to MQTT Broker at {mqtt_broker}")
   except:
       logging.error("Failed to publish data")

@flask.route("/")
def welcome_message():
    return jsonify({"message":"Hello from Local-dost"})

@flask.route("/ground_team_data", methods=['GET'])
def ground_data():
    ground_team = {
        "aircraft_position": {
            "latitude": round(random.uniform(-90, 90), 6),
            "longitude": round(random.uniform(-180, 180), 6),
            "altitude": round(random.uniform(0, 500), 2),  # Ground altitude in meters
        },
        "taxi_routes": {
            "current_taxiway": f"Taxiway {random.choice(['A', 'B', 'C', 'D', 'E'])}",
            "next_runway": f"Runway {random.choice([10, 18, 25, 36])}",
        },
        "refueling": {
            "status": random.choice(["In-progress", "Completed"]),
            "fuel_level": round(random.uniform(1000, 20000), 2),  # Fuel level in liters
            "fuel_type": random.choice(["Jet A", "Jet A-1", "AVGas"]),
        },
        "baggage_cargo_loading": {
            "total_weight": round(random.uniform(1000, 20000), 2),  # Weight in kilograms
            "cargo_distribution": random.choice(["Even", "Uneven"]),
        },
        "aircraft_maintenance": {
            "status": random.choice(["Completed", "Pending", "Ongoing"]),
            "check_type": random.choice(["Pre-flight", "Scheduled", "Unscheduled"]),
        },
        "passenger_boarding": {
            "status": random.choice(["Boarding", "Completed", "In-Progress"]),
            "passenger_count": random.randint(50, 300),  # Number of passengers
        },
        "ground_support_vehicles": {
            "available_tugs": random.randint(1, 5),
            "catering_trucks": random.randint(1, 3),
            "baggage_vehicles": random.randint(2, 10),
            "fuel_trucks": random.randint(2, 12),
            "cleaning_trucks": random.randint(1, 10),
        },
    }
    return jsonify(ground_team)

@flask.route("/atc_data", methods=['GET'])
def atc_data():
    flight_names = [
        "AF123", "BA456", "UA789", "DL101", "EK205", "LH401", "QF25", "NZ5", "JL37", "AC857", 
        "EY12", "QR17", "VS500", "CX880", "SV871", "AS6", "KL606", "SQ321", "TK196", "LH401", 
        "AI202", "CI788", "TG910", "MU358", "AI155", "BA255", "QR15", "AA245", "NZ11", "SU104", 
        "IB51", "TK3"
    ]
    
    destinations = [
        "New York", "London", "Paris", "Tokyo", "Los Angeles", "Dubai", "Berlin", "Sydney", "Rome", "San Francisco",
        "Chicago", "Beijing", "Hong Kong", "Mumbai", "Amsterdam", "Singapore", "Madrid", "Bangkok", "Toronto", "Shanghai", 
        "Frankfurt", "Doha", "Lagos", "Mexico City", "Boston", "Barcelona", "Seoul", "Istanbul", "Moscow", "Zurich", 
        "Cairo", "Jakarta"
    ]
    
    atc_team = {
        "flight_details": {
            "flight_name": random.choice(flight_names),
            "source": random.choice(destinations), 
            "destination": random.choice(destinations), 
            "flight_type": random.choice(["Commercial", "Cargo", "Private", "Military"]),
        },
        "aircraft_position": {
            "latitude": round(random.uniform(-90, 90), 6),
            "longitude": round(random.uniform(-180, 180), 6),
            "altitude": round(random.uniform(3000, 45000), 2),  # Altitude in feet
        },
        "flight_paths": {
            "current_route": f"Route {random.choice(['1A', '2B', '3C', '4D'])}",
            "next_waypoint": f"Waypoint {random.choice(['WPT1', 'WPT2', 'WPT3', 'WPT4'])}",
        },
        "separation_and_sequencing": {
            "horizontal_separation": round(random.uniform(5, 15), 2),  # Nautical miles
            "vertical_separation": round(random.uniform(1000, 5000), 2),  # Feet
        },
        "altitude_and_speed": {
            "current_altitude": round(random.uniform(10000, 40000), 2),  # Altitude in feet
            "current_speed": round(random.uniform(200, 600), 2),  # Speed in knots
        },
        "weather_conditions": {
            "current_weather": random.choice(["Clear", "Cloudy", "Windy", "Thunderstorms"]),
            "wind_speed": round(random.uniform(0, 100), 2),  # Wind speed in knots
            "turbulence": random.choice(["None", "Light", "Moderate", "Severe"]),
        },
        "traffic_conflict_alerts": {
            "alert_status": random.choice(["None", "Potential", "Imminent"]),
            "resolved": random.choice(["True", "False"]),
        },
        "landing_and_departure_clearances": {
            "departure_clearance": random.choice(["Issued", "Pending"]),
            "landing_clearance": random.choice(["Issued", "Pending"]),
        },
    }

    return jsonify(atc_team)

@flask.route("/airInFlightData", methods=['GET'])
def airInFlightData():
    aifData = {
        "aircraft_position": {
            "latitude": round(random.uniform(-90, 90), 6),
            "longitude": round(random.uniform(-180, 180), 6),
            "altitude": round(random.uniform(3000, 45000), 2),  # Altitude in feet
        },
        "altitude_and_airspeed": {
            "altitude": round(random.uniform(10000, 35000), 2),  # Altitude in feet
            "airspeed": round(random.uniform(200, 500), 2),  # Airspeed in knots
        },
        "fuel_consumption": {
            "current_level": round(random.uniform(1000, 20000), 2),  # Fuel level in liters
            "rate_of_consumption": round(random.uniform(500, 3000), 2),  # Rate in liters per hour
        },
        "weight_and_balance": {
            "total_weight": round(random.uniform(30000, 80000), 2),  # Total weight in kilograms
            "cargo_distribution": random.choice(["Balanced", "Unbalanced"]),
        },
        "engine_performance": {
            "engine_1_status": random.choice(["Operational", "Failure"]),
            "engine_2_status": random.choice(["Operational", "Failure"]),
            "performance_parameters": {
                "engine_1_thrust": round(random.uniform(50, 100), 2),  # Percentage of max thrust
                "engine_2_thrust": round(random.uniform(50, 100), 2),
                "fuel_efficiency": round(random.uniform(0.5, 2.0), 2),  # Fuel efficiency in kg per hour
            },
        },
        "navigation_systems": {
            "gps_status": random.choice(["Operational", "Malfunctioning"]),
            "current_waypoint": f"WP{random.randint(1, 10)}",
        },
        "weather_conditions": {
            "turbulence": random.choice(["None", "Light", "Moderate", "Severe"]),
            "wind_speed": round(random.uniform(0, 100), 2),  # Wind speed in knots
            "cloud_cover": round(random.uniform(0, 100), 2),  # Percentage
        },
        "flight_instruments": {
            "altimeter": round(random.uniform(10000, 35000), 2),  # Altimeter reading in feet
            "attitude_indicator": random.choice(["Level", "Climbing", "Descending"]),
            "speed_indicator": round(random.uniform(200, 500), 2),  # Speed in knots
            "vertical_speed_indicator": round(random.uniform(-5000, 5000), 2),  # Feet per minute
        },
        "emergency_protocols": {
            "status": random.choice(["None", "Engine Failure", "Medical Emergency", "Cabin Pressure Loss"]),
            "response": random.choice(["Initiated", "Not Required"]),
        },
        "passenger_safety": {
            "cabin_pressure": round(random.uniform(7000, 8000), 2),  # Cabin pressure in feet
            "oxygen_levels": round(random.uniform(90, 100), 2),  # Oxygen levels in percentage
            "medical_emergencies": random.choice([True, False]),
        },
        "cabin_crew_coordination": {
            "communication_status": random.choice(["Ongoing", "Complete"]),
            "emergency_training_status": random.choice(["Completed", "Pending"]),
        },
    }
    return jsonify(aifData)

@flask.route("/environment_data", methods=['GET'])
def envData():
    weatherData = {
        "temperature": round(random.uniform(-40, 50), 2),  # Temperature in Celsius
        "humidity": round(random.uniform(0, 100), 2),  # Humidity in percentage
        "pressure": round(random.uniform(900, 1050), 2),  # Atmospheric pressure in hPa
        "wind_speed": round(random.uniform(0, 100), 2),  # Wind speed in km/h
        "precipitation": round(random.uniform(0, 500), 2),  # Precipitation in mm
        "visibility": round(random.uniform(0, 100), 2),  # Visibility in kilometers
        "cloud_cover": round(random.uniform(0, 100), 2),  # Cloud cover in percentage
        "dew_point": round(random.uniform(-40, 35), 2),  # Dew point in Celsius
    }
    return jsonify(weatherData)

if __name__ == "__main__":
    connect_to_mqtt()
    flask.run(debug=True, port=8000, host="0.0.0.0")
    while True:
        publish_data()
        time.sleep(2)