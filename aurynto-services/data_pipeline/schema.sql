-- Create the assets table
CREATE TABLE IF NOT EXISTS assets (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active'
);

-- Create the telemetry table
CREATE TABLE IF NOT EXISTS telemetry (
    id SERIAL PRIMARY KEY,
    asset_id VARCHAR(50),
    timestamp TIMESTAMPTZ DEFAULT now(),
    speed NUMERIC,
    temperature NUMERIC,
    fuel_level NUMERIC,
    load_weight NUMERIC,
    engine_temp NUMERIC,
    coolant_temp NUMERIC,
    rpm NUMERIC,
    engine_hours NUMERIC,
    battery_v NUMERIC,
    asset_table_id INTEGER REFERENCES assets(id)
);

-- Convert to a hypertable (TimescaleDB)
SELECT create_hypertable('telemetry', 'timestamp', if_not_exists => TRUE);

-- Create the jobs table
CREATE TABLE IF NOT EXISTS jobs (
    job_id SERIAL PRIMARY KEY,
    asset_id INTEGER REFERENCES assets(id),
    operator VARCHAR(100),
    status VARCHAR(20) DEFAULT 'pending',
    eta TIMESTAMPTZ
);

-- Add the sample data
INSERT INTO assets (type, location, status) VALUES 
    ('crane', 'Construction Site A', 'active'),
ON CONFLICT DO NOTHING;


-- Bus telemetry table
CREATE TABLE IF NOT EXISTS bus_telemetry (
    asset_id VARCHAR(50) NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    speed NUMERIC,
    temperature NUMERIC,
    fuel_level NUMERIC,
    engine_temp NUMERIC,
    battery_v NUMERIC,
    odometer_km NUMERIC,
    door_status VARCHAR(10),
    passenger_count INTEGER,
    gear_position VARCHAR(5),
    location geometry(Point,4326),
    asset_table_id INTEGER REFERENCES assets(id),
    PRIMARY KEY (asset_id, timestamp)
);

SELECT create_hypertable('bus_telemetry', 'timestamp', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS idx_bus_telemetry_location ON bus_telemetry USING GIST (location);

-- Add bus asset
INSERT INTO assets (type, location, status) VALUES 
    ('bus', 'Transit Route 42', 'active')
ON CONFLICT DO NOTHING;

