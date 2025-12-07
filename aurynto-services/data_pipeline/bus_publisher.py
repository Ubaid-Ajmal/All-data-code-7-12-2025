# Bus telemetry publisher
import paho.mqtt.client as mqtt
import time
import json
import random
from datetime import datetime
import logging
from dotenv import load_dotenv
import os

# GPS coordinates for bus route (adjust for your city)
LAT_MIN, LAT_MAX = 43.6, 43.7  
LON_MIN, LON_MAX = -79.5, -79.3  

# Load bus-specific config
load_dotenv('.env.bus')

log_level = os.getenv('LOG_LEVEL', 'INFO')
logging.basicConfig(
    level=getattr(logging, log_level),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('publisher_bus.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

MQTT_BROKER = os.getenv('MQTT_BROKER')
MQTT_PORT = int(os.getenv('MQTT_PORT'))
MQTT_TOPIC = os.getenv('MQTT_TOPIC')
PUBLISH_INTERVAL = int(os.getenv('PUBLISH_INTERVAL'))
ASSET_ID = os.getenv('ASSET_ID')
ASSET_TABLE_ID = int(os.getenv('ASSET_TABLE_ID'))

client = mqtt.Client()
try:
    client.connect(MQTT_BROKER, MQTT_PORT)
    client.loop_start()
    time.sleep(2)
    logger.info(f"Bus publisher connected to MQTT broker on topic {MQTT_TOPIC}")
except Exception as e:
    logger.exception("Failed to connect to MQTT broker")
    exit(1)

while True:
    message_to_send = {
        "asset_id": ASSET_ID,
        "asset_table_id": ASSET_TABLE_ID,
        "timestamp": datetime.utcnow().isoformat(),
        "speed": round(random.uniform(0, 80), 2),  # Buses go faster than cranes
        "temperature": round(random.uniform(15, 35), 1),  # Cabin temperature
        "fuel_level": round(random.uniform(10, 100), 1),
        "engine_temp": round(random.uniform(80, 110), 1),
        "battery_v": round(random.uniform(11.5, 14.5), 1),
        # Bus-specific fields
        "odometer_km": round(random.uniform(50000, 300000), 1),
        "door_status": random.choice(["OPEN", "CLOSED"]),
        "passenger_count": random.randint(0, 45),
        "gear_position": random.choice(["P", "R", "N", "D"]),
        # GPS
        "latitude": round(random.uniform(LAT_MIN, LAT_MAX), 6),
        "longitude": round(random.uniform(LON_MIN, LON_MAX), 6)
    }
    
    client.publish(MQTT_TOPIC, json.dumps(message_to_send))
    logger.info(f"Published bus telemetry for {ASSET_ID} - passengers: {message_to_send['passenger_count']}, doors: {message_to_send['door_status']}")
    time.sleep(PUBLISH_INTERVAL)