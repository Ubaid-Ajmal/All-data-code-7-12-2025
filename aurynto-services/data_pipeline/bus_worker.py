import time
import paho.mqtt.client as mqtt
import psycopg2
import json
import logging
from dotenv import load_dotenv
import os
import threading

# Load bus-specific config
load_dotenv('.env.bus')

log_level = os.getenv('LOG_LEVEL', 'INFO')
logging.basicConfig(
    level=getattr(logging, log_level),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('worker_bus.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# PostgreSQL connection
conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    port=os.getenv('DB_PORT')
)
cur = conn.cursor()

MQTT_BROKER = os.getenv('MQTT_BROKER')
MQTT_PORT = int(os.getenv('MQTT_PORT'))
TOPIC = os.getenv('MQTT_TOPIC')

message_buffer = []
BATCH_SIZE = int(os.getenv('BATCH_SIZE', 100))
BATCH_TIMEOUT = int(os.getenv('BATCH_TIMEOUT', 30))
last_insert_time = time.time()

def periodic_flush():
    while True:
        time.sleep(BATCH_TIMEOUT)
        flush_buffer()

flush_thread = threading.Thread(target=periodic_flush, daemon=True)
flush_thread.start()

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        logger.info("Bus worker connected to MQTT broker successfully")
        client.subscribe(TOPIC)
        logger.info(f"Subscribed to topic: {TOPIC}")
    else:
        logger.error(f"Failed to connect to MQTT broker, return code {rc}")

def flush_buffer():
    global message_buffer
    
    if not message_buffer:
        return
    
    try:
        logger.info(f"Flushing bus buffer with {len(message_buffer)} messages")
        
        values = [
            (
                msg['asset_id'],
                msg['timestamp'],
                msg.get('speed'),
                msg.get('temperature'),
                msg.get('fuel_level'),
                msg.get('engine_temp'),
                msg.get('battery_v'),
                msg.get('odometer_km'),
                msg.get('door_status'),
                msg.get('passenger_count'),
                msg.get('gear_position'),
                msg.get('asset_table_id'),
                f"SRID=4326;POINT({msg.get('longitude')} {msg.get('latitude')})" if msg.get('longitude') and msg.get('latitude') else None
            )
            for msg in message_buffer
        ]
        
        cur.executemany("""
            INSERT INTO bus_telemetry (
                asset_id, timestamp, speed, temperature, 
                fuel_level, engine_temp, battery_v,
                odometer_km, door_status, passenger_count, gear_position,
                asset_table_id, location
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, ST_GeomFromEWKT(%s))
        """, values)
        
        conn.commit()
        logger.info(f"Successfully inserted {len(message_buffer)} bus records")
        message_buffer = []
        
    except psycopg2.Error as e:
        logger.exception(f"Database error during batch insert: {e}")
        conn.rollback()
        message_buffer = []
    except Exception as e:
        logger.exception(f"Unexpected error during batch insert: {e}")
        message_buffer = []

def on_message(client, userdata, msg):
    global message_buffer, last_insert_time
    
    logger.debug("Bus worker received a message")
    try:
        data = json.loads(msg.payload.decode())
        logger.debug(f"Decoded message: {data}")
        
        message_buffer.append(data)
        logger.debug(f"Buffer size: {len(message_buffer)}")
        
        current_time = time.time()
        time_since_last_insert = current_time - last_insert_time
        
        if len(message_buffer) >= BATCH_SIZE or time_since_last_insert >= BATCH_TIMEOUT:
            flush_buffer()
            last_insert_time = current_time
            
    except json.JSONDecodeError as e:
        logger.error(f"Failed to decode JSON: {e}")
    except Exception as e:
        logger.exception(f"Unexpected error: {e}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

logger.info("Connecting to MQTT broker...")
client.connect(MQTT_BROKER, MQTT_PORT)

client.loop_forever()