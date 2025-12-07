from fastapi import FastAPI
from fastapi import Query
from datetime import datetime
from dotenv import load_dotenv
import psycopg2
import os

load_dotenv()

app = FastAPI()


# Database connection function
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST'),
        database=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        port=os.getenv('DB_PORT')
    )

# The endpoint
@app.get("/telemetry/recent/{asset_id}")
def get_recent_telemetry(asset_id: str):
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT asset_id, timestamp, speed, temperature, 
            fuel_level, load_weight, engine_temp, coolant_temp,
            rpm, engine_hours, battery_v,
            ST_X(location) as longitude,
            ST_Y(location) as latitude
        FROM telemetry 
        WHERE asset_id = %s 
        ORDER BY timestamp DESC 
        LIMIT 10
    """, (asset_id,))

    rows = cur.fetchall()
    cur.close()
    conn.close()

    # Update column names to include GPS
    column_names = ['asset_id', 'timestamp', 'speed', 'temperature', 
                'fuel_level', 'load_weight', 'engine_temp', 'coolant_temp',
                'rpm', 'engine_hours', 'battery_v', 'longitude', 'latitude']

    results = [
        {column_names[i]: (str(value) if column_names[i] == 'timestamp' else value) 
        for i, value in enumerate(row)}
        for row in rows
    ]

    return results

@app.get("/telemetry/history/{asset_id}")
def get_telemetry_history(
    asset_id: str,
    from_time: str = Query(..., alias="from"),
    to_time: str = Query(..., alias="to")
):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT asset_id, timestamp, speed, temperature,
               fuel_level, load_weight, engine_temp, coolant_temp,
               rpm, engine_hours, battery_v
        FROM telemetry
        WHERE asset_id = %s 
          AND timestamp >= %s 
          AND timestamp <= %s
        ORDER BY timestamp DESC
    """, (asset_id, from_time, to_time))
    
    rows = cur.fetchall()
    cur.close()
    conn.close()
    
    column_names = ['asset_id', 'timestamp', 'speed', 'temperature',
                    'fuel_level', 'load_weight', 'engine_temp', 'coolant_temp',
                    'rpm', 'engine_hours', 'battery_v']
    
    results = [
        {column_names[i]: (str(value) if column_names[i] == 'timestamp' else value)
         for i, value in enumerate(row)}
        for row in rows
    ]
    
    return results

#for the front end to be able to get all information at once from the api
#for craneX for example, do: GET /assets/craneX/state, and do http://127.0.0.1:8000/assets/craneX/state

@app.get("/assets/{asset_id}/state")
def get_asset_state(asset_id: str):
    conn = get_db_connection()
    cur = conn.cursor()
    
    # Get the most recent telemetry with location
    cur.execute("""
        SELECT 
            t.asset_id,
            t.timestamp,
            t.speed,
            t.temperature,
            t.fuel_level,
            t.load_weight,
            t.engine_temp,
            t.coolant_temp,
            t.rpm,
            t.engine_hours,
            t.battery_v,
            ST_X(t.location) as longitude,
            ST_Y(t.location) as latitude,
            a.type,
            a.location as site_location,
            a.status
        FROM telemetry t
        JOIN assets a ON t.asset_table_id = a.id
        WHERE t.asset_id = %s
        ORDER BY t.timestamp DESC
        LIMIT 1
    """, (asset_id,))
    
    row = cur.fetchone()
    cur.close()
    conn.close()
    
    if not row:
        return {"error": "Asset not found or no telemetry data"}
    
    # Format the response
    result = {
        "asset_id": row[0],
        "last_updated": str(row[1]),
        "telemetry": {
            "speed": row[2],
            "temperature": row[3],
            "fuel_level": row[4],
            "load_weight": row[5],
            "engine_temp": row[6],
            "coolant_temp": row[7],
            "rpm": row[8],
            "engine_hours": row[9],
            "battery_voltage": row[10]
        },
        "location": {
            "longitude": row[11],
            "latitude": row[12]
        },
        "asset_info": {
            "type": row[13],
            "site": row[14],
            "status": row[15]
        }
    }
    
    return result

# Bus-specific endpoints
@app.get("/bus/telemetry/recent/{asset_id}")
def get_recent_bus_telemetry(asset_id: str):
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT asset_id, timestamp, speed, temperature, 
            fuel_level, engine_temp, battery_v,
            odometer_km, door_status, passenger_count, gear_position,
            ST_X(location) as longitude,
            ST_Y(location) as latitude
        FROM bus_telemetry 
        WHERE asset_id = %s 
        ORDER BY timestamp DESC 
        LIMIT 10
    """, (asset_id,))

    rows = cur.fetchall()
    cur.close()
    conn.close()

    column_names = ['asset_id', 'timestamp', 'speed', 'temperature', 
                    'fuel_level', 'engine_temp', 'battery_v',
                    'odometer_km', 'door_status', 'passenger_count', 'gear_position',
                    'longitude', 'latitude']

    results = [
        {column_names[i]: (str(value) if column_names[i] == 'timestamp' else value) 
         for i, value in enumerate(row)}
        for row in rows
    ]

    return results

@app.get("/bus/assets/{asset_id}/state")
def get_bus_state(asset_id: str):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT 
            t.asset_id,
            t.timestamp,
            t.speed,
            t.temperature,
            t.fuel_level,
            t.engine_temp,
            t.battery_v,
            t.odometer_km,
            t.door_status,
            t.passenger_count,
            t.gear_position,
            ST_X(t.location) as longitude,
            ST_Y(t.location) as latitude,
            a.type,
            a.location as site_location,
            a.status
        FROM bus_telemetry t
        JOIN assets a ON t.asset_table_id = a.id
        WHERE t.asset_id = %s
        ORDER BY t.timestamp DESC
        LIMIT 1
    """, (asset_id,))
    
    row = cur.fetchone()
    cur.close()
    conn.close()
    
    if not row:
        return {"error": "Bus not found or no telemetry data"}
    
    result = {
        "asset_id": row[0],
        "last_updated": str(row[1]),
        "telemetry": {
            "speed": row[2],
            "temperature": row[3],
            "fuel_level": row[4],
            "engine_temp": row[5],
            "battery_voltage": row[6],
            "odometer_km": row[7],
            "door_status": row[8],
            "passenger_count": row[9],
            "gear_position": row[10]
        },
        "location": {
            "longitude": row[11],
            "latitude": row[12]
        },
        "asset_info": {
            "type": row[13],
            "route": row[14],
            "status": row[15]
        }
    }
    
    return result