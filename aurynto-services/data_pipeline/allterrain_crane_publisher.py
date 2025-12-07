#The publisher simulates a crane by sending telemetry data over MQTT
#info: asset_id, timestamp, speed, and temperature
# this is a mobile crane

import paho.mqtt.client as mqtt
import time
import json
import random
from datetime import datetime
import logging
from dotenv import load_dotenv
import os

LAT_MIN, LAT_MAX = 40, 50  
LON_MIN, LON_MAX = -79, -79.9  

load_dotenv()
log_level = os.getenv('LOG_LEVEL', 'INFO')
logging.basicConfig(
    level=getattr(logging, log_level),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('publisher.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

MQTT_BROKER = os.getenv('MQTT_BROKER')
MQTT_PORT = int(os.getenv('MQTT_PORT'))
PUBLISH_INTERVAL = int(os.getenv('PUBLISH_INTERVAL'))
ASSET_ID = os.getenv('ASSET_ID')
ASSET_TABLE_ID = int(os.getenv('ASSET_TABLE_ID'))


client = mqtt.Client()
try:
    client.connect(MQTT_BROKER, MQTT_PORT)
    client.loop_start()
    time.sleep(2)
    logger.info("Connected to MQTT broker")
except Exception as e:
    logger.exception("Failed to connect to MQTT broker")
    exit(1)

while True:
    message_to_send = {"asset_id": ASSET_ID,
                       "asset_table_id": ASSET_TABLE_ID,
                       "timestamp": datetime.utcnow().isoformat(),
                       "speed": round(random.uniform(0, 35), 2),
                       "temperature": round(random.uniform(0, 100), 1),
                       "fuel_level": round(random.uniform(10, 100), 1),    
                        "load_weight": round(random.uniform(0, 5000), 0),   # Load in kg
                        "engine_temp": round(random.uniform(80, 120), 1),   
                        "coolant_temp": round(random.uniform(70, 100), 1),  
                        "rpm": round(random.uniform(800, 3000), 0),         
                        "engine_hours": round(random.uniform(100, 5000), 1), 
                        "battery_v": round(random.uniform(5000, 20000), 1),
                        "boom_length": round(random.uniform(16, 80), 1),
                        "boom_angle": round(random.uniform(0, 360), 1),
                        "outrigger_extended": random.choice(["True", "False"]),
                        "steering_mode": random.choice(["crab", "coordinated", "front"]),
                        "drive_mode": random.choice(["On Road", "Off Road"]),
                        "latitude": round(random.uniform(LAT_MIN, LAT_MAX), 6),
                        "longitude": round(random.uniform(LON_MIN, LON_MAX), 6)}
    client.publish("crane/telemetry", json.dumps(message_to_send))
    logger.info(f"Published telemetry for {message_to_send['asset_id']}")
    time.sleep(PUBLISH_INTERVAL) # this loop keeps sending the data of some crane to the broker every 10 seconds
