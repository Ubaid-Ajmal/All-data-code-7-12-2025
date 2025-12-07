--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 15.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data (Community Edition)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: telemetry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telemetry (
    asset_id text NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    speed numeric,
    temperature numeric,
    fuel_level numeric,
    load_weight numeric,
    engine_temp numeric,
    coolant_temp numeric,
    rpm numeric,
    engine_hours numeric,
    battery_v numeric,
    asset_table_id integer
);


ALTER TABLE public.telemetry OWNER TO postgres;

--
-- Name: _direct_view_5; Type: VIEW; Schema: _timescaledb_internal; Owner: postgres
--

CREATE VIEW _timescaledb_internal._direct_view_5 AS
 SELECT telemetry.asset_id,
    public.time_bucket('01:00:00'::interval, telemetry."timestamp") AS bucket,
    avg(telemetry.speed) AS avg_speed,
    avg(telemetry.temperature) AS avg_temperature,
    avg(telemetry.fuel_level) AS avg_fuel_level,
    avg(telemetry.rpm) AS avg_rpm,
    count(*) AS reading_count
   FROM public.telemetry
  GROUP BY telemetry.asset_id, (public.time_bucket('01:00:00'::interval, telemetry."timestamp"));


ALTER TABLE _timescaledb_internal._direct_view_5 OWNER TO postgres;

--
-- Name: _hyper_4_2_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_4_2_chunk (
    CONSTRAINT constraint_2 CHECK ((("timestamp" >= '2025-09-18 00:00:00+00'::timestamp with time zone) AND ("timestamp" < '2025-09-25 00:00:00+00'::timestamp with time zone)))
)
INHERITS (public.telemetry);


ALTER TABLE _timescaledb_internal._hyper_4_2_chunk OWNER TO postgres;

--
-- Name: _hyper_4_3_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_4_3_chunk (
    CONSTRAINT constraint_3 CHECK ((("timestamp" >= '2025-09-25 00:00:00+00'::timestamp with time zone) AND ("timestamp" < '2025-10-02 00:00:00+00'::timestamp with time zone)))
)
INHERITS (public.telemetry);


ALTER TABLE _timescaledb_internal._hyper_4_3_chunk OWNER TO postgres;

--
-- Name: _materialized_hypertable_5; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._materialized_hypertable_5 (
    asset_id text,
    bucket timestamp with time zone NOT NULL,
    avg_speed numeric,
    avg_temperature numeric,
    avg_fuel_level numeric,
    avg_rpm numeric,
    reading_count bigint
);


ALTER TABLE _timescaledb_internal._materialized_hypertable_5 OWNER TO postgres;

--
-- Name: _hyper_5_4_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_5_4_chunk (
    CONSTRAINT constraint_4 CHECK (((bucket >= '2025-07-31 00:00:00+00'::timestamp with time zone) AND (bucket < '2025-10-09 00:00:00+00'::timestamp with time zone)))
)
INHERITS (_timescaledb_internal._materialized_hypertable_5);


ALTER TABLE _timescaledb_internal._hyper_5_4_chunk OWNER TO postgres;

--
-- Name: _partial_view_5; Type: VIEW; Schema: _timescaledb_internal; Owner: postgres
--

CREATE VIEW _timescaledb_internal._partial_view_5 AS
 SELECT telemetry.asset_id,
    public.time_bucket('01:00:00'::interval, telemetry."timestamp") AS bucket,
    avg(telemetry.speed) AS avg_speed,
    avg(telemetry.temperature) AS avg_temperature,
    avg(telemetry.fuel_level) AS avg_fuel_level,
    avg(telemetry.rpm) AS avg_rpm,
    count(*) AS reading_count
   FROM public.telemetry
  GROUP BY telemetry.asset_id, (public.time_bucket('01:00:00'::interval, telemetry."timestamp"));


ALTER TABLE _timescaledb_internal._partial_view_5 OWNER TO postgres;

--
-- Name: assets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assets (
    id integer NOT NULL,
    type character varying(50) NOT NULL,
    location character varying(100),
    status character varying(20) DEFAULT 'active'::character varying
);


ALTER TABLE public.assets OWNER TO postgres;

--
-- Name: assets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.assets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.assets_id_seq OWNER TO postgres;

--
-- Name: assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.assets_id_seq OWNED BY public.assets.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    job_id integer NOT NULL,
    asset_id integer,
    operator character varying(100),
    status character varying(20) DEFAULT 'pending'::character varying,
    eta timestamp with time zone
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- Name: jobs_job_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jobs_job_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jobs_job_id_seq OWNER TO postgres;

--
-- Name: jobs_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jobs_job_id_seq OWNED BY public.jobs.job_id;


--
-- Name: telemetry_hourly; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.telemetry_hourly AS
 SELECT _materialized_hypertable_5.asset_id,
    _materialized_hypertable_5.bucket,
    _materialized_hypertable_5.avg_speed,
    _materialized_hypertable_5.avg_temperature,
    _materialized_hypertable_5.avg_fuel_level,
    _materialized_hypertable_5.avg_rpm,
    _materialized_hypertable_5.reading_count
   FROM _timescaledb_internal._materialized_hypertable_5;


ALTER TABLE public.telemetry_hourly OWNER TO postgres;

--
-- Name: assets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assets ALTER COLUMN id SET DEFAULT nextval('public.assets_id_seq'::regclass);


--
-- Name: jobs job_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs ALTER COLUMN job_id SET DEFAULT nextval('public.jobs_job_id_seq'::regclass);


--
-- Data for Name: hypertable; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.hypertable (id, schema_name, table_name, associated_schema_name, associated_table_prefix, num_dimensions, chunk_sizing_func_schema, chunk_sizing_func_name, chunk_target_size, compression_state, compressed_hypertable_id, status) FROM stdin;
4	public	telemetry	_timescaledb_internal	_hyper_4	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
5	_timescaledb_internal	_materialized_hypertable_5	_timescaledb_internal	_hyper_5	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
\.


--
-- Data for Name: chunk; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.chunk (id, hypertable_id, schema_name, table_name, compressed_chunk_id, dropped, status, osm_chunk, creation_time) FROM stdin;
2	4	_timescaledb_internal	_hyper_4_2_chunk	\N	f	0	f	2025-09-24 01:28:17.341455+00
3	4	_timescaledb_internal	_hyper_4_3_chunk	\N	f	0	f	2025-09-28 18:52:51.567482+00
4	5	_timescaledb_internal	_hyper_5_4_chunk	\N	f	0	f	2025-10-01 06:15:29.025748+00
\.


--
-- Data for Name: chunk_column_stats; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.chunk_column_stats (id, hypertable_id, chunk_id, column_name, range_start, range_end, valid) FROM stdin;
\.


--
-- Data for Name: dimension; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.dimension (id, hypertable_id, column_name, column_type, aligned, num_slices, partitioning_func_schema, partitioning_func, interval_length, compress_interval_length, integer_now_func_schema, integer_now_func) FROM stdin;
4	4	timestamp	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
5	5	bucket	timestamp with time zone	t	\N	\N	\N	6048000000000	\N	\N	\N
\.


--
-- Data for Name: dimension_slice; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.dimension_slice (id, dimension_id, range_start, range_end) FROM stdin;
2	4	1758153600000000	1758758400000000
3	4	1758758400000000	1759363200000000
4	5	1753920000000000	1759968000000000
\.


--
-- Data for Name: chunk_constraint; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.chunk_constraint (chunk_id, dimension_slice_id, constraint_name, hypertable_constraint_name) FROM stdin;
2	2	constraint_2	\N
2	\N	2_2_telemetry_pkey	telemetry_pkey
3	3	constraint_3	\N
3	\N	3_3_telemetry_pkey	telemetry_pkey
2	\N	2_4_telemetry_asset_table_id_fkey	telemetry_asset_table_id_fkey
3	\N	3_5_telemetry_asset_table_id_fkey	telemetry_asset_table_id_fkey
4	4	constraint_4	\N
\.


--
-- Data for Name: compression_chunk_size; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.compression_chunk_size (chunk_id, compressed_chunk_id, uncompressed_heap_size, uncompressed_toast_size, uncompressed_index_size, compressed_heap_size, compressed_toast_size, compressed_index_size, numrows_pre_compression, numrows_post_compression, numrows_frozen_immediately) FROM stdin;
\.


--
-- Data for Name: compression_settings; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.compression_settings (relid, compress_relid, segmentby, orderby, orderby_desc, orderby_nullsfirst, index) FROM stdin;
\.


--
-- Data for Name: continuous_agg; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_agg (mat_hypertable_id, raw_hypertable_id, parent_mat_hypertable_id, user_view_schema, user_view_name, partial_view_schema, partial_view_name, direct_view_schema, direct_view_name, materialized_only, finalized) FROM stdin;
5	4	\N	public	telemetry_hourly	_timescaledb_internal	_partial_view_5	_timescaledb_internal	_direct_view_5	t	t
\.


--
-- Data for Name: continuous_agg_migrate_plan; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_agg_migrate_plan (mat_hypertable_id, start_ts, end_ts, user_view_definition) FROM stdin;
\.


--
-- Data for Name: continuous_agg_migrate_plan_step; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_agg_migrate_plan_step (mat_hypertable_id, step_id, status, start_ts, end_ts, type, config) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_bucket_function; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_bucket_function (mat_hypertable_id, bucket_func, bucket_width, bucket_origin, bucket_offset, bucket_timezone, bucket_fixed_width) FROM stdin;
5	public.time_bucket(interval,timestamp with time zone)	01:00:00	\N	\N	\N	t
\.


--
-- Data for Name: continuous_aggs_hypertable_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_hypertable_invalidation_log (hypertable_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_invalidation_threshold; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_invalidation_threshold (hypertable_id, watermark) FROM stdin;
4	1759417200000000
\.


--
-- Data for Name: continuous_aggs_materialization_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_materialization_invalidation_log (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
5	-9223372036854775808	-210866803200000001
5	1759176000000000	1759291199999999
5	1759327200000000	1759373999999999
5	1759377600000000	1759381199999999
5	1759417200000000	9223372036854775807
\.


--
-- Data for Name: continuous_aggs_materialization_ranges; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_materialization_ranges (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_watermark; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_watermark (mat_hypertable_id, watermark) FROM stdin;
5	1759176000000000
\.


--
-- Data for Name: metadata; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.metadata (key, value, include_in_telemetry) FROM stdin;
install_timestamp	2025-09-23 22:29:43.761977+00	t
timescaledb_version	2.22.0	f
exported_uuid	d10f9e06-b080-48fb-90de-e1142dff28a4	t
\.


--
-- Data for Name: tablespace; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.tablespace (id, hypertable_id, tablespace_name) FROM stdin;
\.


--
-- Data for Name: bgw_job; Type: TABLE DATA; Schema: _timescaledb_config; Owner: postgres
--

COPY _timescaledb_config.bgw_job (id, application_name, schedule_interval, max_runtime, max_retries, retry_period, proc_schema, proc_name, owner, scheduled, fixed_schedule, initial_start, hypertable_id, config, check_schema, check_name, timezone) FROM stdin;
1000	Refresh Continuous Aggregate Policy [1000]	01:00:00	00:00:00	-1	01:00:00	_timescaledb_functions	policy_refresh_continuous_aggregate	postgres	t	f	\N	5	{"end_offset": "01:00:00", "start_offset": "03:00:00", "mat_hypertable_id": 5}	_timescaledb_functions	policy_refresh_continuous_aggregate_check	\N
\.


--
-- Data for Name: _hyper_4_2_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_4_2_chunk (asset_id, "timestamp", speed, temperature, fuel_level, load_weight, engine_temp, coolant_temp, rpm, engine_hours, battery_v, asset_table_id) FROM stdin;
craneX	2025-09-24 01:28:17.297633+00	2.66	28.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:28:27.303665+00	9.38	49.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:28:37.310055+00	12.84	76.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:28:47.316767+00	1.7	61.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:28:57.322494+00	15.13	81.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:29:07.327195+00	19.49	42.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:29:17.333236+00	19.98	62.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:29:27.340146+00	31.85	94.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:29:37.344292+00	5.28	61.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:29:47.351895+00	13.43	38.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:29:57.358746+00	23.27	90.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:30:07.361821+00	32.73	43.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:30:17.36491+00	4.71	43.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:30:27.370804+00	4.26	16.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:30:37.374114+00	2.05	80.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:30:47.377211+00	5.22	33.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:30:57.380169+00	23.03	38.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:31:07.382817+00	3.18	26.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:31:17.392351+00	27.0	95.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:31:27.393308+00	4.53	92.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:31:37.39734+00	20.23	50.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:31:47.403352+00	22.33	74.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-24 01:31:57.406705+00	10.05	40.7	\N	\N	\N	\N	\N	\N	\N	1
\.


--
-- Data for Name: _hyper_4_3_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_4_3_chunk (asset_id, "timestamp", speed, temperature, fuel_level, load_weight, engine_temp, coolant_temp, rpm, engine_hours, battery_v, asset_table_id) FROM stdin;
craneX	2025-09-29 01:29:11.762677+00	5.32	94.4	86.1	4077.0	113.8	84.0	1481.0	2890.8	13.2	1
craneX	2025-09-29 01:29:21.770103+00	28.84	12.2	86.1	3318.0	90.6	91.3	2504.0	4750.6	11.8	1
craneX	2025-09-29 01:29:31.777018+00	15.4	84.7	79.6	4124.0	80.9	99.3	1081.0	4292.1	13.1	1
craneX	2025-09-29 01:29:41.782908+00	33.73	24.3	15.1	2217.0	100.0	95.0	1267.0	434.1	12.3	1
craneX	2025-09-29 01:29:51.787183+00	20.71	21.6	14.6	2765.0	102.0	97.4	2097.0	2131.4	12.1	1
craneX	2025-09-29 01:30:01.793215+00	30.04	41.3	46.9	4592.0	112.2	83.2	2006.0	2592.8	12.6	1
craneX	2025-09-29 01:30:11.7988+00	20.43	45.1	68.8	180.0	89.6	91.3	1901.0	2175.8	12.4	1
craneX	2025-09-29 01:30:21.804531+00	15.57	16.4	76.3	4020.0	95.9	96.2	1181.0	3986.0	14.3	1
craneX	2025-09-29 01:30:31.806789+00	31.51	11.4	75.7	4450.0	113.0	77.6	1523.0	1202.7	12.7	1
craneX	2025-09-29 01:30:41.808765+00	23.48	15.4	40.4	671.0	110.7	83.5	2310.0	3186.1	11.6	1
craneX	2025-09-29 01:30:51.810332+00	4.33	7.3	49.5	2360.0	83.7	99.5	2714.0	4566.1	13.0	1
craneX	2025-09-29 01:31:01.81739+00	24.43	65.5	13.0	3914.0	119.3	79.7	1302.0	3148.6	12.6	1
craneX	2025-09-29 01:31:11.819807+00	30.09	2.6	20.4	1634.0	81.4	83.2	2310.0	2398.4	13.7	1
craneX	2025-09-29 01:31:21.824751+00	17.74	47.9	54.9	3078.0	80.4	95.7	2425.0	622.7	13.9	1
craneX	2025-09-29 01:31:31.830376+00	15.07	20.5	50.6	1223.0	94.1	93.4	1610.0	3649.1	12.7	1
craneX	2025-09-29 01:31:41.835278+00	19.66	37.5	66.1	4708.0	114.6	93.4	1131.0	1129.9	12.6	1
craneX	2025-09-29 01:31:51.841959+00	5.47	80.1	53.8	4855.0	104.1	89.2	1678.0	1350.2	14.5	1
craneX	2025-09-29 01:32:01.84634+00	34.03	45.2	73.3	4497.0	109.0	72.7	2468.0	1472.4	13.0	1
craneX	2025-09-29 01:32:11.853181+00	1.71	6.2	20.1	4447.0	119.3	78.3	1343.0	103.7	13.0	1
craneX	2025-09-29 01:32:21.857876+00	27.0	15.0	98.5	1426.0	99.7	83.5	2264.0	3917.3	13.2	1
craneX	2025-09-29 01:32:31.863208+00	29.9	8.7	42.9	3878.0	104.7	96.2	1027.0	2826.4	13.2	1
craneX	2025-09-29 01:32:41.866535+00	24.13	46.4	40.8	1887.0	80.0	77.8	2002.0	3779.4	12.6	1
craneX	2025-09-29 01:32:51.871953+00	7.75	63.4	70.5	3383.0	113.1	78.5	2731.0	2652.4	13.4	1
craneX	2025-09-29 01:33:01.875285+00	6.83	97.4	57.2	2902.0	89.3	78.6	2050.0	4650.3	12.2	1
craneX	2025-09-29 01:33:11.882992+00	21.17	48.3	79.0	4561.0	106.3	96.5	2341.0	4683.8	11.9	1
craneX	2025-09-29 01:33:21.889477+00	19.35	78.1	97.3	1682.0	90.7	90.2	2604.0	1894.7	14.1	1
craneX	2025-09-29 01:33:31.893003+00	22.06	41.5	73.2	3526.0	96.3	72.9	908.0	462.6	13.9	1
craneX	2025-09-29 01:33:41.897094+00	19.33	68.2	79.2	2751.0	113.3	87.1	2876.0	3884.6	12.9	1
craneX	2025-09-29 01:33:51.901113+00	9.12	38.7	82.7	2535.0	88.3	95.3	804.0	2621.4	14.1	1
craneX	2025-09-29 01:34:01.907809+00	6.57	29.9	33.0	3583.0	117.0	71.3	1759.0	3114.1	12.2	1
craneX	2025-09-29 01:34:11.914869+00	6.95	55.2	91.9	1491.0	106.3	88.9	1205.0	4933.4	11.9	1
craneX	2025-09-29 01:34:21.921864+00	6.56	84.6	95.8	4953.0	117.4	90.8	2007.0	3365.2	14.3	1
craneX	2025-09-29 01:34:31.924945+00	29.9	53.4	49.5	3482.0	80.2	75.0	1059.0	1191.1	13.0	1
craneX	2025-09-29 01:34:41.931451+00	24.04	7.4	64.9	1115.0	112.7	82.5	803.0	1022.8	14.2	1
craneX	2025-09-29 01:34:51.934876+00	18.9	3.0	13.6	2388.0	115.6	77.7	986.0	2857.8	12.0	1
craneX	2025-09-29 01:35:01.937138+00	7.73	52.9	58.7	4268.0	84.4	70.8	2327.0	743.5	12.0	1
craneX	2025-09-29 01:35:11.943255+00	4.18	82.7	56.4	171.0	95.0	99.2	2202.0	1390.8	13.5	1
craneX	2025-09-29 01:35:21.945177+00	5.28	42.6	54.0	1506.0	87.1	99.7	2031.0	162.1	13.9	1
craneX	2025-09-29 01:35:31.951866+00	31.69	51.3	88.0	2100.0	118.7	72.7	1962.0	3285.1	14.1	1
craneX	2025-09-29 01:35:41.955474+00	3.56	11.4	62.0	2044.0	100.1	98.9	1763.0	432.4	13.2	1
craneX	2025-09-29 01:35:51.959745+00	5.26	6.1	53.0	2897.0	107.8	99.4	1593.0	4775.5	12.3	1
craneX	2025-09-29 01:36:01.96334+00	30.81	4.5	94.9	4562.0	88.7	82.1	2413.0	3977.2	12.1	1
craneX	2025-09-29 01:36:11.967285+00	31.02	56.1	63.6	4301.0	111.9	84.8	1845.0	231.9	13.7	1
craneX	2025-09-29 01:36:21.969329+00	24.35	39.3	90.2	1913.0	112.0	70.0	1379.0	2094.1	12.2	1
craneX	2025-09-29 01:36:31.973566+00	11.77	32.8	63.9	1467.0	114.6	73.7	1206.0	2645.6	13.0	1
craneX	2025-09-29 01:36:41.980422+00	4.97	54.4	56.8	639.0	113.8	86.3	2922.0	2492.2	13.9	1
craneX	2025-09-29 01:36:51.98703+00	11.63	39.0	35.8	3487.0	119.4	85.7	1288.0	4255.0	14.4	1
craneX	2025-09-29 01:37:01.992288+00	22.86	45.5	90.1	1092.0	86.2	90.1	2808.0	2528.8	14.1	1
craneX	2025-09-29 01:37:11.998234+00	7.15	79.1	10.8	1200.0	109.0	83.0	1176.0	1791.5	14.4	1
craneX	2025-09-29 01:37:22.004236+00	13.02	1.6	60.9	3747.0	101.9	95.0	2433.0	2032.8	11.6	1
craneX	2025-09-29 01:37:32.008296+00	27.51	37.4	17.3	947.0	89.3	87.4	1589.0	2057.5	13.1	1
craneX	2025-09-29 01:37:42.013162+00	9.89	32.6	48.3	1582.0	115.5	77.6	1052.0	4909.2	12.3	1
craneX	2025-09-29 01:37:52.018494+00	27.28	99.7	68.3	4425.0	117.0	88.3	953.0	1559.1	14.4	1
craneX	2025-09-29 01:38:02.024988+00	1.12	70.3	53.6	156.0	108.6	74.9	2036.0	4952.0	14.0	1
craneX	2025-09-29 01:38:12.026896+00	4.34	89.8	48.7	4023.0	87.2	88.8	1790.0	2637.1	11.6	1
craneX	2025-09-29 01:38:22.031185+00	26.73	73.4	41.1	1831.0	114.0	79.4	2689.0	1809.2	11.8	1
craneX	2025-09-29 01:38:32.034086+00	7.45	17.5	73.9	2157.0	103.6	93.0	1067.0	4335.0	12.1	1
craneX	2025-09-29 01:38:42.038768+00	13.67	76.5	26.2	4436.0	99.4	71.3	1566.0	2769.7	14.2	1
craneX	2025-09-29 01:38:52.045504+00	10.34	28.0	91.9	4308.0	111.9	88.0	1821.0	3778.0	13.8	1
craneX	2025-09-29 01:39:02.048488+00	18.24	3.8	29.7	3137.0	104.0	80.9	2158.0	841.9	12.3	1
craneX	2025-09-29 01:39:12.055637+00	1.35	10.6	78.7	3780.0	112.2	82.1	2996.0	1251.4	14.2	1
craneX	2025-09-29 01:39:22.057245+00	15.26	86.7	80.2	4456.0	95.3	76.9	967.0	1993.9	12.3	1
craneX	2025-09-29 01:39:32.062512+00	31.24	34.3	94.7	3167.0	101.9	79.5	2554.0	2212.4	12.0	1
craneX	2025-09-29 01:39:42.066814+00	26.02	61.4	56.7	4324.0	96.3	79.0	2880.0	1919.8	11.7	1
craneX	2025-09-29 01:39:52.07153+00	5.19	18.7	58.8	1318.0	82.1	79.1	2529.0	3172.7	12.2	1
craneX	2025-09-29 01:40:02.075445+00	10.12	24.0	97.4	1986.0	86.9	78.9	1205.0	4925.8	13.1	1
craneX	2025-09-29 01:40:12.079682+00	14.23	0.7	25.6	1556.0	95.8	92.5	2558.0	4557.7	14.0	1
craneX	2025-09-29 01:40:22.084036+00	6.07	32.6	22.6	4982.0	85.3	86.0	1190.0	1888.7	11.7	1
craneX	2025-09-29 01:40:32.085145+00	31.97	49.8	19.4	2791.0	115.6	72.1	1998.0	667.4	12.0	1
craneX	2025-09-29 01:40:42.087337+00	25.39	60.6	99.9	460.0	83.2	84.5	1294.0	2358.8	12.4	1
craneX	2025-09-29 01:40:52.091776+00	2.92	77.2	33.2	3648.0	108.7	71.1	2730.0	4768.9	12.6	1
craneX	2025-09-29 01:41:02.094305+00	22.2	0.8	96.4	717.0	102.3	86.6	2071.0	4947.5	12.0	1
craneX	2025-09-29 01:41:12.100866+00	7.23	38.8	41.5	3364.0	81.3	82.1	1029.0	4892.5	13.2	1
craneX	2025-09-29 01:41:22.107093+00	5.38	42.1	18.9	3642.0	93.4	82.6	2163.0	305.7	13.3	1
craneX	2025-09-29 01:41:32.112434+00	30.43	18.6	54.2	1128.0	93.4	87.4	2343.0	3706.0	11.7	1
craneX	2025-09-29 01:41:42.119419+00	31.39	29.6	51.0	2148.0	96.2	87.5	2444.0	4476.4	13.1	1
craneX	2025-09-29 01:41:52.12146+00	17.62	23.0	55.2	4609.0	111.5	72.1	2273.0	853.6	14.3	1
craneX	2025-09-29 01:42:02.127313+00	2.96	93.1	72.5	332.0	104.1	75.5	1053.0	868.4	14.5	1
craneX	2025-09-29 01:42:12.133387+00	24.55	71.5	60.2	2375.0	101.6	76.3	1266.0	4598.7	11.7	1
craneX	2025-09-29 01:42:22.140161+00	28.9	69.9	80.2	153.0	94.4	96.3	1124.0	2179.3	14.3	1
craneX	2025-09-29 01:42:32.143306+00	15.7	77.5	21.8	1489.0	94.6	98.4	2129.0	4100.1	13.5	1
craneX	2025-09-29 01:42:42.149552+00	2.59	69.1	15.7	1789.0	106.1	78.3	2264.0	2459.1	14.1	1
craneX	2025-09-29 01:42:52.155723+00	27.3	64.2	20.5	2083.0	107.3	83.7	2583.0	1482.4	11.7	1
craneX	2025-09-29 01:43:02.16132+00	13.63	51.8	68.3	2169.0	113.1	91.6	1280.0	1961.8	13.8	1
craneX	2025-09-29 01:43:12.164982+00	21.11	69.5	49.1	1945.0	80.1	95.4	1299.0	3349.4	12.1	1
craneX	2025-09-29 01:43:22.170783+00	11.39	67.7	24.5	4277.0	95.5	88.2	1278.0	1640.1	12.3	1
craneX	2025-09-29 01:43:32.17673+00	3.92	17.7	30.8	1904.0	116.4	90.1	2585.0	4060.0	12.1	1
craneX	2025-09-29 01:43:42.181836+00	8.5	87.7	98.1	3617.0	90.5	73.3	1729.0	2380.5	13.0	1
craneX	2025-09-29 01:43:52.184236+00	10.0	9.5	35.2	3392.0	86.9	71.7	1746.0	412.2	13.8	1
craneX	2025-09-29 01:44:02.186274+00	0.52	80.6	28.7	2673.0	119.1	84.3	1832.0	558.0	11.7	1
craneX	2025-09-29 01:44:12.193457+00	33.72	20.0	73.6	3752.0	96.1	73.0	960.0	3013.0	11.6	1
craneX	2025-09-29 01:44:22.199544+00	7.19	33.5	78.1	2037.0	83.0	94.9	854.0	4430.5	13.1	1
craneX	2025-09-29 01:44:32.209655+00	34.64	7.4	36.5	614.0	86.9	77.9	1030.0	3132.8	11.8	1
craneX	2025-09-29 01:44:42.219181+00	33.03	34.3	28.4	209.0	100.1	75.6	2249.0	3371.7	13.5	1
craneX	2025-09-29 01:44:52.225609+00	13.16	67.0	50.0	2349.0	86.0	84.0	2814.0	3361.7	14.1	1
craneX	2025-09-29 01:45:02.230677+00	9.23	46.8	93.2	488.0	99.7	76.4	1170.0	495.7	12.7	1
craneX	2025-09-29 01:45:12.236252+00	19.15	8.7	58.9	4266.0	103.0	90.1	2269.0	3334.6	13.8	1
craneX	2025-09-29 01:45:22.239759+00	4.57	44.0	42.5	501.0	81.3	95.6	2826.0	171.5	12.2	1
craneX	2025-09-29 01:45:32.246118+00	22.04	71.7	71.6	2320.0	96.7	93.1	1639.0	387.1	11.7	1
craneX	2025-09-29 01:45:42.250939+00	4.01	20.8	69.5	4745.0	116.2	72.5	2230.0	1266.8	14.2	1
craneX	2025-09-29 01:45:52.258261+00	27.2	28.9	22.4	3251.0	93.0	78.1	1143.0	1663.4	14.2	1
craneX	2025-09-29 01:46:02.264167+00	9.75	22.9	87.9	499.0	109.7	98.7	1004.0	2546.4	12.0	1
craneX	2025-09-29 01:46:12.267476+00	28.22	74.0	84.1	4114.0	92.6	78.0	2521.0	1354.7	13.3	1
craneX	2025-09-29 01:46:22.268814+00	20.58	37.1	16.4	2021.0	93.0	97.0	2514.0	4799.2	14.4	1
craneX	2025-09-29 01:46:32.273799+00	33.3	41.8	79.0	1011.0	84.0	96.3	2846.0	1690.3	13.2	1
craneX	2025-09-29 01:46:42.276276+00	7.76	38.1	16.6	1230.0	105.1	86.0	2019.0	2405.9	14.3	1
craneX	2025-09-29 01:46:52.283653+00	31.1	22.5	55.0	596.0	114.6	78.3	2029.0	2598.5	11.9	1
craneX	2025-09-29 01:47:02.290484+00	33.06	80.7	69.9	1996.0	92.2	84.9	1208.0	983.5	12.9	1
craneX	2025-09-29 01:47:12.29666+00	26.56	65.1	94.9	405.0	117.9	93.6	2350.0	2809.8	11.6	1
craneX	2025-09-29 01:47:22.303324+00	31.3	47.5	69.8	1353.0	88.1	74.2	1618.0	3412.1	11.9	1
craneX	2025-09-29 01:47:32.320886+00	22.76	70.3	55.8	80.0	97.8	89.1	802.0	4301.2	12.4	1
craneX	2025-09-29 01:47:42.324121+00	4.46	20.2	38.8	667.0	111.2	87.1	1434.0	2506.0	14.1	1
craneX	2025-09-29 01:47:52.326679+00	3.51	29.7	63.1	3388.0	94.7	90.1	2042.0	853.0	12.8	1
craneX	2025-09-29 01:48:02.332699+00	6.66	35.9	41.3	1102.0	111.6	83.9	1671.0	2267.5	13.3	1
craneX	2025-09-29 01:48:12.338609+00	30.78	75.1	27.3	4146.0	81.2	96.5	2072.0	2927.3	12.5	1
craneX	2025-09-29 01:48:22.344828+00	5.98	15.6	20.2	880.0	109.2	79.6	1280.0	1683.7	13.4	1
craneX	2025-09-29 01:48:32.350191+00	29.79	90.7	78.0	3709.0	96.1	85.7	813.0	3450.1	12.3	1
craneX	2025-09-29 01:48:42.355212+00	29.31	22.4	34.7	3807.0	86.7	88.7	2737.0	1910.0	13.3	1
craneX	2025-09-29 01:48:52.361698+00	22.12	98.1	13.0	1427.0	100.1	98.5	2302.0	298.2	12.1	1
craneX	2025-09-29 01:49:02.367282+00	7.06	25.1	28.2	4614.0	91.9	89.5	2446.0	1384.8	11.5	1
craneX	2025-09-29 01:49:12.370954+00	26.01	13.7	42.3	4921.0	117.4	97.7	862.0	1491.9	12.5	1
craneX	2025-09-29 01:49:22.37666+00	28.91	55.0	22.2	4165.0	92.9	80.6	1074.0	2295.6	12.8	1
craneX	2025-09-29 01:49:32.38383+00	0.57	59.9	68.8	775.0	90.2	70.6	1915.0	2666.6	13.0	1
craneX	2025-09-29 01:49:42.389952+00	5.01	45.3	73.8	1595.0	84.1	87.3	2416.0	3259.2	13.5	1
craneX	2025-09-29 01:49:52.403962+00	5.2	12.6	73.6	4472.0	118.4	80.3	1384.0	651.1	13.7	1
craneX	2025-09-29 01:50:02.407727+00	26.94	4.4	11.7	2558.0	82.8	74.6	2362.0	1473.0	13.2	1
craneX	2025-09-29 01:50:12.414052+00	14.83	38.9	87.8	4764.0	91.5	78.6	1870.0	741.1	14.0	1
craneX	2025-09-29 01:50:22.419701+00	24.47	5.5	94.9	159.0	96.2	73.9	2804.0	797.9	11.9	1
craneX	2025-09-29 01:50:32.423015+00	12.86	4.8	59.5	4678.0	88.9	92.3	2012.0	408.3	13.4	1
craneX	2025-09-29 01:50:42.427212+00	25.78	12.1	27.0	2339.0	106.1	94.2	1443.0	4990.3	11.9	1
craneX	2025-09-29 01:50:52.432286+00	13.02	0.6	30.4	1854.0	82.3	94.5	1527.0	3189.4	13.9	1
craneX	2025-09-29 01:51:02.438754+00	8.76	55.6	95.5	2875.0	103.9	83.2	1080.0	1868.1	11.7	1
craneX	2025-09-29 01:51:12.44434+00	6.53	90.3	13.8	4964.0	84.6	95.9	1585.0	1319.4	12.4	1
craneX	2025-09-29 01:51:22.452192+00	16.53	83.3	73.3	170.0	85.5	82.2	2551.0	4257.7	13.7	1
craneX	2025-09-29 01:51:32.458474+00	18.15	75.7	56.5	3385.0	104.8	76.1	2368.0	3770.5	13.5	1
craneX	2025-09-29 01:51:42.462262+00	3.36	32.4	84.1	3229.0	90.8	98.8	1552.0	3055.7	12.4	1
craneX	2025-09-29 01:51:52.468251+00	28.67	96.9	42.8	112.0	105.6	91.7	1197.0	2756.4	12.3	1
craneX	2025-09-29 01:52:02.469078+00	21.12	67.1	91.1	2828.0	83.0	86.0	2029.0	1291.9	11.8	1
craneX	2025-09-29 01:52:12.474763+00	2.16	94.8	66.1	1024.0	86.8	98.8	1159.0	989.6	12.2	1
craneX	2025-09-29 01:52:22.477734+00	23.92	96.6	21.8	1440.0	113.5	73.4	2841.0	2025.1	12.5	1
craneX	2025-09-29 01:52:32.48361+00	33.32	64.7	32.3	1119.0	105.7	97.3	2836.0	1682.2	14.4	1
craneX	2025-09-29 01:52:42.48954+00	8.44	78.3	38.0	2710.0	101.1	79.3	988.0	574.0	13.1	1
craneX	2025-09-29 01:52:52.495481+00	14.59	45.1	44.3	2404.0	96.3	83.8	2834.0	292.5	11.9	1
craneX	2025-09-29 01:53:02.499897+00	31.23	23.0	44.3	1973.0	119.6	95.2	1049.0	2823.6	13.2	1
craneX	2025-09-29 01:53:12.505715+00	28.45	99.0	35.9	582.0	117.1	98.2	856.0	1205.4	12.7	1
craneX	2025-09-29 01:53:22.509548+00	32.43	64.0	29.2	213.0	81.7	77.9	1697.0	2496.4	12.2	1
craneX	2025-09-29 01:53:32.515837+00	1.04	21.6	35.4	1712.0	108.5	72.8	2317.0	3312.6	14.2	1
craneX	2025-09-29 01:53:42.519712+00	17.8	63.8	87.1	1445.0	99.1	98.8	2079.0	1180.4	12.2	1
craneX	2025-09-29 01:53:52.524922+00	21.39	60.9	72.8	3565.0	95.6	91.6	1643.0	427.5	14.3	1
craneX	2025-09-29 01:54:02.528678+00	11.89	1.2	89.7	1656.0	95.3	89.9	1173.0	4777.5	11.7	1
craneX	2025-09-29 01:54:12.532069+00	18.14	67.0	77.1	937.0	91.9	99.9	2996.0	244.6	13.2	1
craneX	2025-09-29 01:54:22.536991+00	8.54	47.4	34.5	1872.0	97.0	75.5	1015.0	3411.9	12.9	1
craneX	2025-09-29 01:54:32.540113+00	15.34	14.8	60.7	3064.0	116.1	95.8	2356.0	1567.2	13.4	1
craneX	2025-09-29 01:54:42.541994+00	26.87	8.6	53.0	3700.0	98.4	86.1	1291.0	4197.2	13.7	1
craneX	2025-09-29 01:54:52.546776+00	1.62	50.0	56.1	3017.0	119.8	73.3	1820.0	2440.1	13.5	1
craneX	2025-09-29 01:55:02.553912+00	5.34	88.4	21.7	2996.0	80.8	81.9	1007.0	2983.7	14.4	1
craneX	2025-09-29 01:55:12.557691+00	27.14	82.4	38.0	206.0	91.7	76.9	2198.0	1547.2	12.7	1
craneX	2025-09-29 01:55:22.56353+00	6.0	81.5	14.2	4379.0	112.8	78.5	1341.0	531.1	14.0	1
craneX	2025-09-29 01:55:32.567126+00	2.46	75.4	49.9	4862.0	98.9	84.2	2303.0	3087.7	13.7	1
craneX	2025-09-29 01:55:42.57116+00	34.9	57.0	48.6	4283.0	117.5	72.3	2330.0	4087.4	14.4	1
craneX	2025-09-29 18:54:28.050066+00	29.14	0.9	19.8	4177.0	117.7	88.9	1586.0	2000.1	14.4	1
craneX	2025-09-29 18:54:38.05739+00	13.78	35.1	78.5	1802.0	102.2	71.5	1200.0	2107.4	13.4	1
craneX	2025-09-29 18:54:48.067213+00	10.82	39.1	74.8	2314.0	99.0	79.7	1928.0	278.8	11.9	1
craneX	2025-09-29 18:54:58.074021+00	26.01	75.8	13.0	156.0	119.4	83.7	1441.0	3484.8	14.4	1
craneX	2025-09-29 18:55:08.081924+00	16.04	42.5	42.7	4646.0	86.2	75.9	2256.0	1034.8	13.6	1
craneX	2025-09-29 18:55:18.099054+00	24.01	81.0	90.9	4340.0	105.1	72.1	875.0	3439.1	13.8	1
craneX	2025-09-29 18:55:28.11169+00	2.75	80.5	75.5	137.0	103.0	70.2	2711.0	1563.6	11.8	1
craneX	2025-09-29 18:55:38.127238+00	8.03	35.4	35.9	2932.0	105.8	99.0	2661.0	2803.0	13.8	1
craneX	2025-09-29 18:55:48.133433+00	17.46	6.8	12.4	451.0	83.7	77.5	2572.0	1581.6	14.1	1
craneX	2025-09-29 18:55:58.140175+00	32.29	54.1	84.1	4580.0	103.5	77.4	942.0	4781.1	12.1	1
craneX	2025-09-29 18:56:08.149877+00	28.8	74.3	46.9	3617.0	107.1	85.7	1403.0	133.1	13.4	1
craneX	2025-09-29 18:56:18.151897+00	31.54	97.8	42.0	4094.0	102.6	95.7	1817.0	4086.2	13.5	1
craneX	2025-09-29 18:56:28.160876+00	26.22	81.2	20.5	1231.0	83.0	76.0	2549.0	3482.0	13.4	1
craneX	2025-09-29 18:56:38.165165+00	25.32	22.1	67.8	3353.0	95.0	76.0	1155.0	904.9	14.4	1
craneX	2025-09-29 18:56:48.17212+00	26.82	36.0	98.3	559.0	118.9	98.7	2797.0	2824.9	12.8	1
craneX	2025-09-29 18:56:58.179419+00	34.93	76.2	35.1	2917.0	101.9	73.2	2761.0	2532.3	13.1	1
craneX	2025-09-29 18:57:08.18542+00	15.83	12.0	28.5	1298.0	103.2	72.0	1020.0	3821.0	13.6	1
craneX	2025-09-29 18:57:18.195841+00	11.31	46.7	20.9	4726.0	95.5	99.0	2840.0	3493.2	13.6	1
craneX	2025-09-29 18:57:28.203673+00	33.67	73.1	35.2	2149.0	83.8	97.3	1805.0	1454.3	13.8	1
craneX	2025-09-29 18:57:38.210176+00	27.2	5.5	55.8	3349.0	86.5	93.9	2048.0	3393.8	12.1	1
craneX	2025-09-29 18:57:48.212926+00	17.18	88.8	62.9	2072.0	92.3	74.7	2152.0	2989.0	14.4	1
craneX	2025-09-29 18:57:58.215283+00	19.63	34.0	23.9	4177.0	116.0	75.1	2786.0	4782.3	11.7	1
craneX	2025-09-29 18:58:08.222565+00	9.14	5.2	33.3	1943.0	99.7	77.1	2935.0	2393.8	14.2	1
craneX	2025-09-29 18:58:18.230036+00	18.33	0.7	95.9	1089.0	103.6	73.6	1030.0	1112.3	12.7	1
craneX	2025-09-29 18:58:28.232165+00	32.93	81.2	88.6	1343.0	91.5	94.5	821.0	738.5	13.7	1
craneX	2025-09-29 18:58:38.239033+00	34.26	71.8	46.7	2037.0	82.1	88.1	804.0	459.3	13.9	1
craneX	2025-09-29 18:58:48.244776+00	4.39	11.2	59.4	2149.0	82.7	83.1	2540.0	335.3	11.6	1
craneX	2025-09-29 18:58:58.251931+00	31.69	58.4	94.3	3881.0	107.9	92.9	2280.0	1385.8	13.5	1
craneX	2025-09-29 18:59:08.257477+00	9.97	66.1	28.0	274.0	102.8	90.6	2192.0	2556.0	12.5	1
craneX	2025-09-29 18:59:18.262804+00	29.52	83.1	91.0	2205.0	108.0	72.8	2521.0	2013.7	11.5	1
craneX	2025-09-29 18:59:28.267264+00	11.34	95.6	55.1	4410.0	89.0	77.3	1779.0	3256.4	11.8	1
craneX	2025-09-29 18:59:38.269109+00	25.43	54.4	50.5	4684.0	95.9	70.1	1070.0	4197.7	12.7	1
craneX	2025-09-29 18:59:48.272727+00	10.87	73.6	57.7	4722.0	96.5	86.2	1146.0	1138.8	14.1	1
craneX	2025-09-29 18:59:58.27897+00	4.63	41.1	13.4	122.0	96.6	96.9	2425.0	362.7	12.7	1
craneX	2025-09-29 19:00:08.283227+00	22.06	97.3	15.9	4667.0	83.0	94.1	2940.0	1094.1	13.6	1
craneX	2025-09-29 19:00:18.29081+00	30.82	79.1	79.8	4416.0	109.7	76.5	2686.0	395.4	11.9	1
craneX	2025-09-28 18:52:51.53068+00	28.45	67.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:53:01.536241+00	18.07	70.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:53:11.539765+00	33.49	15.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:53:21.546067+00	11.53	88.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:53:31.553191+00	9.07	38.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:53:41.559038+00	33.29	0.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:53:51.564698+00	25.05	32.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:54:01.569004+00	23.58	27.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:54:11.575536+00	6.04	53.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:54:21.58133+00	28.7	34.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:54:31.583969+00	21.29	70.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:54:41.585283+00	5.38	59.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:54:51.591251+00	11.0	16.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:55:01.595736+00	0.42	38.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:55:11.600395+00	14.09	88.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:55:21.605217+00	14.91	30.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:55:31.611097+00	0.63	38.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:55:41.615956+00	23.28	39.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:55:51.623123+00	21.34	40.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:56:01.625157+00	20.58	55.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:56:11.630894+00	10.68	73.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:56:21.633817+00	29.19	67.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:56:31.639176+00	29.44	40.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:56:41.645553+00	29.84	10.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:56:51.650953+00	5.89	3.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:57:01.657121+00	7.95	5.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:57:11.662997+00	26.85	68.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:57:21.668951+00	21.29	75.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:57:31.675916+00	1.62	15.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:57:41.678675+00	30.36	45.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:57:51.685096+00	14.82	48.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:58:01.686383+00	1.42	66.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:58:11.690133+00	33.35	23.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:58:21.694274+00	11.23	56.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:58:31.696088+00	6.83	29.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:58:41.701798+00	2.07	74.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:58:51.703614+00	25.26	13.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:59:01.710144+00	19.93	16.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:59:11.712941+00	19.28	71.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:59:21.715606+00	4.37	7.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:59:31.722678+00	7.74	80.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:59:41.724869+00	23.22	19.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 18:59:51.726816+00	21.37	44.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:00:01.732095+00	21.19	66.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:00:11.734446+00	22.3	99.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:00:21.740341+00	20.37	42.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:00:31.743284+00	11.74	59.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:00:41.749025+00	16.25	62.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:00:51.755045+00	13.0	87.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:01:01.759362+00	12.89	6.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:01:11.761492+00	18.11	23.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:01:21.762839+00	20.91	34.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:01:31.767142+00	24.88	25.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:01:41.771958+00	2.32	78.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:01:51.776748+00	34.87	72.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:02:01.782862+00	34.98	45.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:02:11.793597+00	30.21	19.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:02:21.797996+00	31.2	31.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:02:31.80508+00	27.76	21.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:02:41.810712+00	3.0	46.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:02:51.816436+00	19.17	43.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:03:01.822466+00	20.21	55.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:03:11.826981+00	23.77	43.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:03:21.832705+00	16.45	41.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:03:31.838842+00	26.08	73.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:03:41.844222+00	6.25	88.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:03:51.850043+00	10.46	4.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:04:01.856095+00	28.31	96.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:04:11.8619+00	24.75	43.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:04:21.865878+00	29.58	58.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:04:31.871927+00	13.46	88.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:04:41.874701+00	1.13	64.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:04:51.880345+00	21.07	7.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:05:01.882008+00	15.48	3.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:05:11.88495+00	1.95	52.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:05:21.887091+00	11.11	43.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:05:31.889077+00	23.02	89.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:05:41.893777+00	33.71	78.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:05:51.899618+00	33.15	93.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:06:01.902235+00	25.85	11.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:06:11.908154+00	34.53	19.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:06:21.915064+00	1.56	40.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:06:31.919892+00	23.79	19.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:06:41.926375+00	32.75	72.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:06:51.933224+00	24.67	38.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:07:01.935956+00	20.69	93.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:07:11.946007+00	26.23	16.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:07:21.951557+00	20.77	61.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:07:31.956262+00	34.92	46.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:07:41.971973+00	28.31	27.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:07:51.976112+00	3.56	51.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:08:01.982641+00	3.14	82.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:08:11.987011+00	10.32	52.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:08:21.994848+00	0.74	93.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:08:31.998415+00	5.83	29.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:08:42.005026+00	12.03	82.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:08:52.007769+00	11.81	30.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:09:02.009467+00	21.93	15.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:09:12.016818+00	20.26	41.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:09:22.018963+00	25.14	65.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:09:32.023256+00	34.39	96.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:09:42.025615+00	27.92	28.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:09:52.02625+00	24.46	41.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:10:02.031807+00	12.11	46.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:10:12.03843+00	18.07	94.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:10:22.042867+00	22.49	97.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:10:32.048566+00	1.16	30.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:10:42.053222+00	22.87	59.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:10:52.05635+00	13.09	26.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:11:02.060989+00	3.15	72.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:11:12.065884+00	10.5	61.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:11:22.069761+00	25.09	68.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:11:32.074648+00	3.69	17.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:11:42.080609+00	2.93	54.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:11:52.081241+00	9.13	98.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:12:02.087612+00	17.93	79.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:12:12.093121+00	0.93	53.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:12:22.098803+00	32.07	30.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:12:32.103396+00	30.78	16.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:12:42.10843+00	24.78	49.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:12:52.114229+00	29.71	33.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:13:02.120499+00	24.32	74.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:13:12.12379+00	16.23	36.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:13:22.12879+00	5.05	70.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:26:04.359669+00	1.0	53.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:13:32.131141+00	30.31	6.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:13:42.138004+00	20.78	36.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:13:52.140333+00	34.14	31.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:14:02.144173+00	12.62	69.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:14:12.147723+00	0.15	25.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:14:22.154563+00	0.27	86.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:14:32.157846+00	5.24	91.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:14:42.164+00	13.39	19.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:14:52.169882+00	16.85	5.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:15:02.174279+00	19.09	73.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:15:12.179079+00	31.09	6.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:15:22.180996+00	24.46	49.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:15:32.185601+00	22.47	51.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:15:42.191891+00	4.42	99.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:15:52.198054+00	1.3	81.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:16:02.204531+00	33.5	53.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:16:12.207511+00	2.62	99.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:16:22.214011+00	28.68	98.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:16:32.215203+00	29.37	20.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:16:42.218746+00	11.3	45.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:16:52.22505+00	23.1	82.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:17:02.23165+00	19.0	15.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:17:12.235437+00	17.45	14.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:17:22.237598+00	22.62	84.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:17:32.239362+00	4.44	16.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:17:42.243445+00	32.41	51.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:17:52.246265+00	9.1	58.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:18:02.250644+00	20.59	43.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:18:12.252781+00	21.29	28.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:18:22.259613+00	32.13	85.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:18:32.264471+00	10.53	21.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:18:42.268149+00	3.97	69.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:18:52.275487+00	11.64	78.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:19:02.289679+00	13.55	37.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:19:12.295788+00	4.57	31.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:19:22.301117+00	30.9	17.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:19:32.305394+00	4.64	50.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:19:42.313226+00	17.92	56.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:19:52.319279+00	23.42	54.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:20:02.323047+00	23.35	21.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:20:12.329321+00	0.86	89.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:20:22.334239+00	0.37	71.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:20:32.33764+00	13.41	24.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:20:42.344416+00	15.16	56.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:20:52.348234+00	0.52	76.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:21:02.354714+00	6.38	76.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:21:12.360549+00	16.39	28.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:21:22.366561+00	0.17	37.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:21:32.372334+00	33.65	33.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:21:42.378457+00	33.61	77.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:21:52.382352+00	29.06	34.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:22:02.387593+00	29.34	77.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:22:12.390571+00	7.88	48.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:22:22.394871+00	20.97	46.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:22:32.400835+00	23.7	89.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:22:42.403925+00	9.6	68.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:22:52.406581+00	0.36	9.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:23:02.408778+00	29.8	48.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:23:12.411329+00	29.76	70.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:23:22.412899+00	33.88	9.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:23:32.419911+00	14.52	18.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:23:42.426817+00	34.61	14.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:23:52.433062+00	22.54	16.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:24:02.437066+00	24.09	46.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:24:12.443078+00	17.79	42.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:24:22.446055+00	6.45	44.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:24:32.448912+00	11.94	29.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:24:42.453848+00	31.65	25.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:24:52.459608+00	27.23	1.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:25:02.464942+00	14.14	34.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:25:12.471377+00	13.27	57.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:25:22.475051+00	32.14	3.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:25:32.477351+00	14.43	45.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:25:42.482331+00	20.8	33.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:25:52.488009+00	23.91	96.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:26:02.490203+00	22.3	69.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:26:12.492527+00	16.36	6.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:26:22.497626+00	9.85	11.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:26:32.504023+00	17.34	47.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:26:42.51231+00	3.5	54.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:26:52.519681+00	1.98	24.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:27:02.526439+00	2.77	94.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:27:12.534107+00	3.64	74.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:27:22.538046+00	3.57	57.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:27:32.545536+00	21.56	58.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:27:42.552957+00	28.33	94.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:27:52.558081+00	31.02	56.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:28:02.563522+00	25.96	61.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:28:12.566253+00	5.06	11.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:28:22.572237+00	28.8	61.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:28:32.576215+00	24.87	55.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:28:42.57767+00	18.43	28.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:28:52.583185+00	29.95	79.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:29:02.587472+00	20.86	86.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:29:12.593195+00	2.99	57.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:29:22.598706+00	3.7	57.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:29:32.60199+00	12.74	6.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:29:42.605918+00	34.22	10.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:29:52.608861+00	14.55	22.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:30:02.61475+00	24.7	22.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:30:12.619934+00	24.26	74.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:30:22.624066+00	8.3	48.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:30:32.629948+00	23.92	31.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:30:42.633918+00	31.56	57.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:30:52.638432+00	1.79	95.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:31:02.641146+00	17.57	7.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:31:12.645559+00	0.83	53.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:31:22.651437+00	30.98	2.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:31:32.656693+00	23.44	90.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:31:42.661303+00	17.57	51.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:31:52.666986+00	23.38	17.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:32:02.672057+00	25.43	55.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:32:12.682286+00	12.94	33.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:32:22.691365+00	33.3	81.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:32:32.695763+00	24.73	86.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:32:42.701893+00	9.97	65.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:32:52.707385+00	2.48	71.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:33:02.713354+00	17.15	96.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:33:12.717407+00	5.59	35.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:33:22.721158+00	11.02	93.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:33:32.727313+00	13.05	4.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:33:42.733025+00	22.91	54.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:33:52.738695+00	11.92	75.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:34:02.744663+00	12.87	5.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:34:12.750354+00	6.93	98.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:34:22.755307+00	2.95	72.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:34:32.761188+00	12.74	35.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:34:42.767062+00	15.76	81.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:34:52.771613+00	34.13	46.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:35:02.775757+00	18.26	55.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:35:12.777531+00	22.07	67.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:35:22.779751+00	21.11	88.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:35:32.784155+00	31.99	3.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:35:42.789946+00	34.78	20.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:35:52.795772+00	9.68	66.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:36:02.799227+00	7.95	39.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:36:12.805335+00	6.62	61.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:36:22.808733+00	8.96	50.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:36:32.814592+00	23.92	82.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:36:42.820421+00	25.63	72.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:36:52.825989+00	13.42	77.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:37:02.829165+00	21.71	29.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:37:12.833872+00	6.4	99.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:37:22.841972+00	29.19	65.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:37:32.853928+00	32.92	68.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:37:42.861044+00	4.02	72.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:37:52.867147+00	15.58	50.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:38:02.873107+00	7.32	58.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:38:12.875832+00	5.62	63.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:38:22.882517+00	2.24	64.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:38:32.887379+00	16.03	3.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:38:42.89318+00	6.7	93.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:38:52.900089+00	8.4	48.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:39:02.905988+00	27.91	8.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:39:12.913568+00	23.92	69.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:39:22.915443+00	13.77	30.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:39:32.932623+00	14.36	97.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:39:42.944941+00	23.73	57.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:39:52.95199+00	6.39	84.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:40:02.956991+00	27.43	77.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:40:12.961347+00	16.74	99.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:40:22.963082+00	27.57	49.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:40:32.970885+00	34.16	8.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:40:42.982265+00	22.98	9.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:40:52.985139+00	14.99	26.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:41:02.989045+00	32.43	79.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:41:12.996011+00	19.47	42.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:41:23.002523+00	10.01	96.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:41:33.011539+00	28.12	68.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:41:43.020445+00	24.27	56.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:41:53.025129+00	28.3	17.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:42:03.03198+00	7.59	73.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:42:13.035164+00	10.23	12.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:42:23.040257+00	1.01	71.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:42:33.050755+00	18.33	38.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:42:43.059013+00	13.71	46.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:42:53.0641+00	14.14	11.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:43:03.066308+00	23.18	2.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:43:13.073439+00	21.57	15.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:43:23.081906+00	31.51	61.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:43:33.083595+00	32.78	87.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:43:43.086433+00	22.91	40.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:43:53.093249+00	12.85	11.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:44:03.097969+00	31.68	44.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:44:13.10094+00	11.75	53.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:44:23.106555+00	27.26	97.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:44:33.113196+00	9.78	7.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:44:43.118791+00	6.1	84.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:44:53.121256+00	14.89	33.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:45:03.127515+00	13.93	26.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:45:13.133971+00	1.87	45.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:45:23.147351+00	23.34	92.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:45:33.162047+00	16.4	36.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:45:43.178115+00	8.34	82.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:45:53.192139+00	7.14	96.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:46:03.195641+00	18.5	53.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:46:13.209331+00	29.11	94.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:46:23.216305+00	5.73	90.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:46:33.221932+00	23.75	2.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:46:43.225417+00	12.08	34.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:46:53.231798+00	24.38	48.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:47:03.236702+00	20.61	66.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:47:13.243219+00	3.94	17.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:47:23.244723+00	18.16	62.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:47:33.250347+00	0.48	34.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:47:43.25472+00	19.5	16.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:47:53.257153+00	16.91	3.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:48:03.259305+00	33.21	81.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:48:13.26281+00	12.88	91.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:48:23.268882+00	21.85	41.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:48:33.273733+00	3.29	25.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:48:43.278491+00	17.55	56.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:48:53.28236+00	2.97	70.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:49:03.287528+00	19.01	74.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:49:13.2895+00	29.08	8.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:49:23.295992+00	6.76	39.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:49:33.299942+00	20.6	45.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:49:43.30226+00	31.49	80.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:49:53.306214+00	18.98	0.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:50:03.312192+00	5.87	18.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:50:13.314435+00	0.33	7.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:50:23.318199+00	11.86	24.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:50:33.323794+00	32.77	99.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:50:43.326857+00	23.16	81.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:50:53.333108+00	1.22	79.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:51:03.336513+00	21.48	39.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:51:13.339434+00	8.82	23.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:51:23.345511+00	19.69	41.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:51:33.350127+00	8.57	65.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:51:43.354572+00	24.14	48.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:51:53.359326+00	29.01	80.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:52:03.362338+00	20.2	95.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:52:13.369414+00	25.87	93.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:52:23.373953+00	8.71	48.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:52:33.378042+00	6.22	48.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:52:43.382375+00	17.85	76.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:52:53.387826+00	14.34	60.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:53:03.393661+00	32.16	94.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:53:13.399985+00	4.44	17.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:53:23.402829+00	13.68	89.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:53:33.406372+00	25.78	21.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:53:43.410429+00	33.96	44.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:53:53.416642+00	34.89	18.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:54:03.419851+00	26.38	70.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:54:13.435188+00	14.5	84.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:54:23.439419+00	10.32	9.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:54:33.444887+00	8.32	75.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:54:43.452076+00	14.05	38.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:54:53.456743+00	24.64	19.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:55:03.460334+00	20.76	68.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:55:13.462784+00	17.61	49.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:55:23.468995+00	7.78	96.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:55:33.4725+00	11.68	45.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:55:43.479523+00	10.49	53.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:55:53.48451+00	0.84	44.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:56:03.49257+00	14.55	14.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:56:13.498917+00	6.93	24.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:56:23.505215+00	0.66	36.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:56:33.513889+00	3.04	25.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:56:43.518501+00	32.28	91.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:56:53.542343+00	17.6	54.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:57:03.548752+00	15.08	17.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:57:13.555916+00	1.53	16.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:57:23.560312+00	32.63	29.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:57:33.565299+00	15.51	33.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:57:43.573257+00	15.27	21.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:57:53.530901+00	19.67	22.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:58:03.53635+00	3.72	49.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:58:13.549839+00	25.64	13.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:58:23.551709+00	12.72	55.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:58:33.557874+00	34.82	29.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:58:43.564454+00	34.21	35.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:58:53.569216+00	6.23	98.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:59:03.572895+00	4.95	89.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:59:13.580514+00	19.19	60.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:59:23.586064+00	27.53	69.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:59:33.588246+00	15.2	59.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:59:43.593019+00	31.39	20.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 19:59:53.596591+00	33.38	6.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:00:03.600758+00	17.77	53.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:00:13.602847+00	32.65	81.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:00:23.60853+00	33.33	31.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:00:33.613914+00	18.76	44.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:00:43.617998+00	18.49	47.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:00:53.624953+00	9.62	14.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:01:03.627924+00	21.32	44.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:01:13.63335+00	1.38	31.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:01:23.637791+00	3.71	47.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:01:33.639624+00	10.17	23.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:01:43.640644+00	1.37	21.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:01:53.645712+00	24.02	83.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:02:03.650615+00	20.44	76.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:02:13.656563+00	29.82	84.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:02:23.662046+00	0.0	4.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:02:33.667818+00	23.16	34.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:02:43.670766+00	23.49	33.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:02:53.673769+00	34.43	10.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:03:03.67826+00	28.69	89.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:03:13.683776+00	4.6	7.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:03:23.688373+00	24.64	54.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:03:33.69068+00	32.98	96.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:03:43.693934+00	1.29	9.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:03:53.699595+00	2.37	73.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:04:03.70093+00	16.6	3.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:04:13.706497+00	33.37	51.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:04:23.709604+00	34.2	38.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:04:33.712965+00	34.82	73.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:04:43.718367+00	1.45	20.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:04:53.723942+00	31.58	13.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:05:03.727594+00	23.29	54.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:05:13.733199+00	0.14	59.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:05:23.744123+00	3.88	46.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:05:33.753058+00	16.82	94.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:05:43.759254+00	4.5	20.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:05:53.762135+00	30.17	62.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:06:03.767469+00	7.33	58.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:06:13.773066+00	33.92	87.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:06:23.777645+00	11.76	86.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:06:33.779496+00	1.15	32.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:06:43.783748+00	20.09	93.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:06:53.789409+00	5.32	65.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:07:03.791254+00	16.01	18.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:07:13.795924+00	15.39	48.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:07:23.797414+00	6.3	75.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:07:33.799878+00	34.48	44.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:07:43.806185+00	5.26	92.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:29:27.339916+00	2.55	81.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:07:53.808368+00	23.13	15.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:08:03.813281+00	24.58	28.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:08:13.815344+00	12.91	72.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:08:23.819771+00	13.29	41.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:08:33.82562+00	12.37	10.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:08:43.83152+00	14.35	0.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:08:53.833432+00	7.14	68.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:09:03.839163+00	32.3	95.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:09:13.841247+00	1.72	19.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:09:23.84634+00	8.92	14.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:09:33.848506+00	28.09	80.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:09:43.849699+00	0.5	20.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:09:53.854114+00	18.87	79.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:10:03.859379+00	19.98	29.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:10:13.861906+00	7.95	58.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:10:23.866933+00	6.47	3.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:10:33.872628+00	26.74	9.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:10:43.877111+00	29.86	2.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:10:53.882684+00	25.6	70.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:11:03.887241+00	6.93	73.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:11:13.88966+00	8.47	33.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:11:23.893279+00	4.12	52.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:11:33.89606+00	26.14	21.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:11:43.899688+00	10.05	90.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:11:53.902628+00	4.94	89.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:12:03.90708+00	20.23	84.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:12:13.912397+00	14.64	61.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:12:23.916717+00	16.64	31.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:12:33.922368+00	32.19	2.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:12:43.92923+00	25.35	74.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:12:53.937855+00	3.14	13.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:13:03.943835+00	31.33	74.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:13:13.946592+00	27.62	74.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:13:23.958164+00	9.63	71.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:13:33.959651+00	31.09	34.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:13:43.961964+00	18.0	44.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:13:53.967508+00	22.49	2.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:14:03.973354+00	24.34	75.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:14:13.97904+00	22.1	42.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:14:23.982753+00	14.97	0.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:14:33.988455+00	31.12	59.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:14:43.994259+00	9.93	52.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:14:54.000047+00	2.37	34.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:15:04.00589+00	8.78	0.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:15:14.011254+00	17.09	75.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:15:24.017202+00	21.76	28.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:15:34.019489+00	14.39	51.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:15:44.020895+00	17.61	76.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:15:54.023057+00	30.82	34.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:16:04.028676+00	30.68	22.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:16:14.032619+00	16.6	9.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:16:24.037152+00	1.94	15.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:16:34.041914+00	24.72	12.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:16:44.044338+00	12.9	39.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:16:54.046714+00	22.52	23.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:17:04.052479+00	18.43	3.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:17:14.055031+00	34.26	94.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:17:24.057265+00	16.02	45.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:17:34.062906+00	6.21	94.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:17:44.068315+00	19.41	61.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:17:54.071889+00	31.11	62.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:18:04.077312+00	34.57	20.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:18:14.083109+00	29.32	29.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:18:24.087534+00	8.3	44.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:18:34.088584+00	24.93	80.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:18:44.092417+00	5.74	57.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:18:54.098038+00	10.34	57.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:19:04.104761+00	19.6	40.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:19:14.107505+00	25.31	34.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:19:24.118491+00	3.55	96.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:19:34.128623+00	13.32	61.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:19:44.137605+00	22.6	16.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:19:54.143971+00	20.22	14.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:20:04.14793+00	32.93	3.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:20:14.149984+00	19.06	34.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:20:24.159328+00	31.46	54.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:20:34.165854+00	34.66	19.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:20:44.169925+00	2.97	85.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:20:54.171502+00	5.71	17.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:21:04.182023+00	11.56	32.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:21:14.185598+00	9.76	35.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:21:24.19013+00	5.22	19.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:21:34.194715+00	7.13	33.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:21:44.200524+00	26.54	51.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:21:54.204285+00	4.14	52.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:22:04.209991+00	26.79	86.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:22:14.215835+00	26.36	2.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:22:24.221628+00	19.8	15.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:22:34.227406+00	28.8	11.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:22:44.244814+00	26.1	20.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:22:54.259862+00	3.49	76.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:23:04.267931+00	17.15	69.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:23:14.276833+00	24.09	7.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:23:24.284531+00	12.35	42.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:23:34.290588+00	19.66	41.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:23:44.296282+00	5.58	34.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:23:54.300639+00	6.99	53.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:24:04.306003+00	4.58	80.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:24:14.307047+00	27.31	24.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:24:24.312978+00	31.23	40.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:24:34.319189+00	1.8	58.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:24:44.322464+00	6.78	86.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:24:54.327955+00	27.46	74.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:25:04.330119+00	5.31	46.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:25:14.336+00	34.75	49.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:25:24.340289+00	7.7	63.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:25:34.34613+00	32.74	44.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:25:44.351939+00	34.69	5.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:25:54.35781+00	15.8	31.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:26:14.364936+00	17.06	60.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:26:24.374505+00	8.87	99.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:26:34.381934+00	24.41	54.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:26:44.391117+00	4.03	96.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:26:54.401631+00	24.03	22.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:27:04.407747+00	30.52	93.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:27:14.409749+00	18.48	56.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:27:24.41422+00	13.65	55.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:27:34.424316+00	15.58	5.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:27:44.434532+00	2.14	19.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:27:54.445051+00	2.83	93.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:28:04.454481+00	6.04	53.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:28:14.460632+00	18.21	29.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:28:24.461905+00	7.55	13.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:28:34.472485+00	34.01	63.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:28:44.474158+00	13.97	43.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:28:54.482646+00	15.35	25.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:29:04.490803+00	19.64	63.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:29:14.50168+00	27.94	69.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:29:24.512494+00	20.05	51.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:29:34.520936+00	24.45	13.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:29:44.524012+00	5.32	52.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:29:54.529823+00	24.39	11.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:30:04.53755+00	28.03	43.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:30:14.54696+00	34.01	64.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:30:24.555696+00	1.04	54.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:30:34.557238+00	5.63	17.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:30:44.563047+00	21.61	30.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:30:54.573929+00	12.54	66.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:31:04.580538+00	1.71	31.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:31:14.593476+00	11.54	5.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:31:24.609476+00	3.79	21.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:31:37.64176+00	20.07	3.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:31:47.654064+00	23.69	62.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:31:57.665635+00	20.99	81.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:32:07.672963+00	17.06	22.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:32:17.678299+00	4.03	82.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:41:24.733525+00	1.47	10.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:41:35.87378+00	18.2	97.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:41:45.886451+00	29.8	35.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:41:55.892404+00	14.48	52.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:42:05.897351+00	6.06	41.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:42:15.90433+00	31.37	22.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:42:25.909595+00	23.01	59.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:42:35.913824+00	27.81	65.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:42:45.916684+00	26.58	44.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:42:55.929599+00	9.18	59.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:43:05.935912+00	15.71	45.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:43:15.93904+00	20.26	75.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:43:25.945366+00	13.66	64.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:43:35.948356+00	7.47	10.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:43:45.954135+00	22.59	51.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:43:55.960442+00	19.9	11.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:44:05.966071+00	24.27	83.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:44:15.96711+00	23.93	10.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:44:25.968447+00	20.77	83.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:44:35.97167+00	31.92	62.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:44:45.974577+00	2.39	61.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:44:55.975617+00	26.04	50.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:45:05.979049+00	8.14	13.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:45:15.981124+00	13.1	58.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:45:25.986794+00	6.03	3.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:45:35.989956+00	11.9	73.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:45:45.995862+00	19.76	74.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:45:55.999981+00	6.25	28.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:46:06.003179+00	29.26	8.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:46:16.007629+00	11.79	58.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:46:26.012351+00	22.65	33.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:46:36.014296+00	31.63	35.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:46:46.019774+00	28.43	46.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:46:56.025357+00	3.55	94.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:47:06.031051+00	27.25	97.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:47:16.036215+00	26.52	36.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:47:26.040042+00	15.8	33.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:47:36.045723+00	15.19	12.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:47:46.046476+00	31.89	5.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:47:56.052886+00	19.52	93.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:48:06.058682+00	23.22	57.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:48:16.061678+00	4.21	29.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:48:26.064768+00	25.41	39.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:48:36.066432+00	12.91	12.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:48:46.070397+00	20.96	81.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:48:56.076005+00	17.13	19.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:49:06.077372+00	27.76	36.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:49:16.080837+00	5.52	19.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:49:26.083999+00	16.66	88.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:49:36.087279+00	25.44	35.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:49:46.090278+00	8.24	86.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:49:56.093332+00	31.11	59.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:50:06.097984+00	22.3	55.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:50:16.103606+00	15.64	85.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:50:26.109059+00	10.83	35.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:50:36.115851+00	25.03	66.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:50:46.117849+00	3.82	15.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:50:56.123591+00	27.85	37.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:51:06.128666+00	9.47	2.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:51:16.134089+00	20.18	40.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:51:26.139104+00	16.23	49.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:51:36.145058+00	19.43	2.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:51:46.151943+00	25.94	53.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:51:56.157588+00	17.96	98.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:52:06.159378+00	8.81	44.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:52:16.162439+00	3.21	12.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:52:26.164981+00	6.52	49.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:52:36.166731+00	5.75	62.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:52:46.172287+00	0.92	41.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:52:56.177503+00	10.85	52.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:53:06.178662+00	32.41	14.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:53:16.182802+00	4.74	52.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:53:26.184016+00	19.21	36.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:53:36.189944+00	17.71	33.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:53:46.196233+00	12.39	53.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:53:56.203698+00	25.88	52.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:54:06.204872+00	14.23	41.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:54:16.211757+00	23.67	70.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:54:26.217396+00	8.92	30.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:54:36.220776+00	21.21	84.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:54:46.223993+00	0.29	84.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:54:56.227922+00	3.76	39.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:55:06.235275+00	27.45	89.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:55:16.240878+00	1.32	5.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:55:26.244834+00	28.5	86.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:55:36.246425+00	33.42	63.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:55:46.25034+00	22.13	88.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:55:56.257433+00	18.09	19.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:56:06.264601+00	32.6	57.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:56:16.286409+00	20.6	6.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:56:26.293031+00	32.23	50.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:56:36.295852+00	32.93	80.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:56:46.297761+00	0.13	38.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:56:56.298836+00	24.98	80.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:57:06.303442+00	23.45	77.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:57:16.307719+00	17.01	51.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:57:26.309438+00	0.17	7.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:57:36.315199+00	31.48	92.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:57:46.31889+00	6.5	50.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:57:56.324852+00	24.74	64.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:58:06.32741+00	17.1	22.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:58:16.333028+00	25.17	24.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:58:26.336972+00	7.36	66.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:58:36.342404+00	1.12	53.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:58:46.346663+00	31.33	44.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:58:56.348979+00	32.83	1.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:59:06.353403+00	10.27	97.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:59:16.357764+00	25.45	59.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:59:26.36275+00	29.46	58.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:59:36.365316+00	20.16	66.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:59:46.369436+00	30.18	38.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 20:59:56.37433+00	28.1	15.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:00:06.378833+00	2.47	70.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:00:16.382221+00	18.01	22.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:00:26.386225+00	0.9	27.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:00:36.391751+00	9.28	67.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:00:46.397517+00	22.64	96.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:00:56.400208+00	15.0	3.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:01:06.405939+00	20.34	99.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:01:16.409373+00	31.59	18.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:01:26.410323+00	8.6	73.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:01:36.415955+00	20.68	63.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:01:46.422581+00	14.97	17.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:01:56.426053+00	23.67	41.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:02:06.428084+00	17.72	66.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:02:16.438355+00	15.74	35.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:02:26.446326+00	5.6	84.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:02:36.457317+00	11.93	97.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:02:46.463064+00	21.67	95.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:02:56.465418+00	25.57	15.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:03:06.477071+00	22.1	0.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:03:16.484603+00	20.49	70.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:03:26.493049+00	3.56	80.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:03:36.503927+00	22.14	66.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:03:46.512561+00	33.99	60.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:03:56.515954+00	26.37	23.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:04:06.52585+00	3.4	11.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:04:16.532681+00	15.86	96.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:04:26.541071+00	0.82	44.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:04:36.542147+00	32.02	56.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:04:46.554224+00	6.99	66.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:04:56.56118+00	24.29	83.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:05:06.566178+00	8.92	27.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:05:16.56738+00	18.9	97.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:05:26.569711+00	31.39	50.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:05:36.573714+00	33.4	71.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:05:46.582916+00	32.73	17.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:05:56.586451+00	8.67	55.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:06:06.597271+00	10.72	0.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:06:16.606066+00	15.87	65.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:06:26.60914+00	2.08	88.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:06:36.615197+00	31.28	73.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:06:46.620379+00	16.79	97.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:06:56.622127+00	32.12	26.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:07:06.625098+00	13.24	92.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:07:16.626715+00	25.73	85.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:07:26.631475+00	30.26	77.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:07:36.63512+00	17.99	18.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:07:46.641197+00	12.14	23.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:07:56.645724+00	9.31	39.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:08:06.651319+00	24.3	82.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:08:16.653479+00	22.99	82.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:08:26.654512+00	8.42	29.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:08:36.658702+00	19.56	44.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:08:46.661327+00	9.4	62.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:08:56.666534+00	27.27	45.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:09:06.668976+00	6.05	36.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:09:16.671636+00	3.86	37.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:09:26.673694+00	10.99	48.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:09:36.675721+00	1.01	39.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:09:46.680585+00	20.48	14.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:09:56.685478+00	16.56	16.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:10:06.686456+00	9.46	80.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:10:16.693239+00	21.27	96.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:10:26.697189+00	18.97	30.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:10:36.703208+00	32.02	79.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:10:46.708344+00	29.95	67.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:10:56.710571+00	11.71	5.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:11:06.712547+00	9.12	31.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:11:16.719209+00	15.04	47.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:29:37.343206+00	19.43	58.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:11:26.721965+00	34.08	72.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:11:36.726896+00	31.73	7.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:11:46.728505+00	10.62	53.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:11:56.733485+00	9.96	99.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:12:06.737949+00	4.05	90.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:12:16.744158+00	10.27	4.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:12:26.750161+00	25.58	95.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:12:36.755414+00	21.58	74.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:12:46.762224+00	2.96	28.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:12:56.768154+00	32.64	54.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:13:06.774045+00	6.41	19.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:13:16.781219+00	34.18	64.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:13:26.783333+00	14.82	10.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:13:36.789467+00	15.97	90.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:13:46.7927+00	26.46	79.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:13:56.798077+00	12.48	19.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:14:06.803564+00	6.32	64.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:14:16.808911+00	18.19	86.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:14:26.813737+00	33.33	38.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:14:36.814911+00	9.1	64.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:14:46.8295+00	28.0	60.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:14:56.835147+00	34.25	19.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:15:06.840544+00	10.58	93.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:15:16.846818+00	21.91	12.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:15:26.850567+00	0.22	64.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:15:36.856765+00	10.66	38.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:15:46.862647+00	4.55	93.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:15:56.869048+00	20.38	39.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:16:06.875194+00	17.58	72.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:16:16.879022+00	8.52	94.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:16:26.884581+00	21.73	32.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:16:36.889975+00	13.98	60.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:16:46.89854+00	4.96	50.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:16:56.906531+00	3.16	18.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:17:06.913195+00	10.59	44.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:17:16.920056+00	29.81	85.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:17:26.92248+00	25.79	78.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:17:36.924624+00	31.35	25.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:17:46.929182+00	5.12	97.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:17:56.933456+00	22.66	16.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:18:06.937909+00	8.27	93.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:18:16.944464+00	4.47	59.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:18:26.945903+00	8.76	32.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:18:36.947754+00	0.07	20.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:18:46.94913+00	16.09	92.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:18:56.953046+00	33.97	11.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:19:06.954363+00	3.5	23.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:19:16.960055+00	26.34	45.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:19:26.962539+00	11.88	50.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:19:36.967821+00	14.07	98.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:19:46.975138+00	6.28	64.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:19:56.976251+00	27.44	62.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:20:06.981906+00	32.85	30.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:20:16.988934+00	1.21	73.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:20:26.994705+00	18.49	32.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:20:37.001785+00	3.15	46.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:20:47.003472+00	31.79	41.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:20:57.007911+00	13.71	65.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:21:07.011308+00	7.58	15.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:21:17.017311+00	11.95	5.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:21:27.020339+00	26.31	98.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:21:37.023448+00	20.88	92.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:21:47.028102+00	22.49	56.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:21:57.034363+00	24.02	55.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:22:07.036259+00	4.36	23.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:22:17.041621+00	27.85	93.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:22:27.042519+00	32.33	54.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:22:37.048112+00	18.62	22.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:22:47.053693+00	5.98	16.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:22:57.059682+00	32.86	76.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:23:07.062051+00	16.38	95.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:23:17.069146+00	32.0	11.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:23:27.073069+00	25.96	42.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:23:37.078662+00	15.9	28.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:23:47.084724+00	29.27	26.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:23:57.091759+00	24.02	53.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:24:07.093415+00	25.61	91.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:24:17.099763+00	27.46	29.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:24:27.104551+00	20.67	48.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:24:37.110462+00	3.44	92.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:24:47.114132+00	24.86	39.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:24:57.118064+00	15.24	71.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:25:07.125751+00	18.47	23.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:25:17.136387+00	31.99	45.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:25:27.144385+00	25.93	41.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:25:37.152196+00	31.54	58.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:25:47.162515+00	26.83	75.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:25:57.171272+00	31.25	29.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:26:07.182393+00	10.33	25.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:26:17.187997+00	13.01	91.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:26:27.19525+00	27.75	37.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:26:37.204846+00	27.89	8.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:26:47.212666+00	7.53	14.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:26:57.2152+00	28.08	12.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:27:07.223842+00	23.82	95.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:27:17.225844+00	17.3	12.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:27:27.230392+00	30.56	44.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:27:37.237991+00	2.27	33.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:27:47.248889+00	5.61	44.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:27:57.25878+00	4.07	24.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:28:07.270061+00	7.53	62.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:28:17.279867+00	3.73	18.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:28:27.290761+00	27.25	60.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:28:37.301355+00	29.42	67.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:28:47.307004+00	16.79	5.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:28:57.30968+00	1.25	40.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:29:07.317866+00	2.68	35.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:29:17.32982+00	13.92	84.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:29:47.350277+00	34.11	54.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:29:57.353805+00	13.5	26.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:30:07.361212+00	14.62	4.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:30:17.366337+00	18.97	63.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:30:27.374673+00	13.06	95.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:30:37.376737+00	19.69	57.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:30:47.385232+00	3.8	56.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:30:57.388172+00	3.17	75.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:31:07.389897+00	11.0	21.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:31:17.400094+00	31.46	0.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:31:27.406122+00	25.64	80.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:31:37.409854+00	34.0	60.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:31:47.41446+00	18.58	83.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:31:57.424539+00	25.51	66.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:32:07.430335+00	5.89	68.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:32:17.431545+00	1.1	40.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:32:27.440966+00	33.42	93.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:32:37.446521+00	12.88	50.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:32:47.448048+00	12.88	30.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:32:57.456593+00	27.99	92.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:33:07.46404+00	12.35	75.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:33:17.472956+00	33.13	94.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:33:27.476165+00	10.16	90.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:33:37.483946+00	21.83	7.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:33:47.493454+00	5.84	24.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:33:57.496942+00	14.37	60.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:34:07.504005+00	23.6	71.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:34:17.50846+00	1.43	8.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:34:27.50683+00	33.95	80.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:34:37.504582+00	19.18	78.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:34:47.50558+00	34.74	81.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:34:57.508574+00	19.11	5.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:35:07.510345+00	18.97	22.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:35:17.517221+00	32.64	79.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:35:27.521799+00	2.23	5.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:35:37.526839+00	18.54	76.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:35:47.534122+00	7.98	68.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:35:57.541338+00	7.57	99.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:36:07.547618+00	34.73	17.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:36:17.555278+00	1.85	66.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:36:27.560798+00	18.73	15.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:36:37.566922+00	7.08	6.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:36:47.572683+00	23.9	20.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:36:57.578591+00	2.37	68.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:37:07.582828+00	20.81	67.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:37:17.588033+00	19.85	99.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:37:27.593454+00	11.44	71.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:37:37.598786+00	13.92	93.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:37:47.60446+00	29.44	68.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:37:57.609801+00	29.78	43.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:38:07.616416+00	16.77	19.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:38:17.622348+00	14.83	4.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:38:27.626967+00	15.95	99.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:38:37.63059+00	14.81	0.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:38:47.637611+00	8.48	96.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:38:57.640439+00	3.8	12.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:39:07.642023+00	27.75	30.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:39:17.649113+00	6.47	9.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:39:27.652932+00	0.91	75.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:39:37.658745+00	14.99	13.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:39:47.663901+00	9.01	64.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:39:57.66976+00	27.8	46.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:40:07.675929+00	8.36	68.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:40:17.681738+00	21.96	75.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:40:27.688462+00	14.56	55.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:40:37.694565+00	11.98	61.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:40:47.70187+00	9.63	57.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:40:57.704489+00	16.17	94.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:41:07.709226+00	28.56	80.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:41:17.712088+00	5.92	91.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:41:27.717681+00	29.62	90.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:41:37.723498+00	3.28	90.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:41:47.728046+00	20.57	74.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:41:57.743503+00	2.1	19.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:42:07.750316+00	0.74	19.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:42:17.751718+00	27.29	66.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:42:27.755087+00	6.45	78.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:42:37.760575+00	9.48	54.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:42:47.764964+00	17.01	12.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:42:57.772131+00	20.58	54.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:43:07.774963+00	9.0	63.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:43:17.782747+00	19.58	7.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:43:27.789038+00	14.7	76.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:43:37.792572+00	2.29	6.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:43:47.796105+00	27.99	63.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:43:57.798722+00	6.34	51.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:44:07.804864+00	16.62	66.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:44:17.808901+00	10.37	71.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:44:27.814995+00	15.84	56.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:44:37.819193+00	3.2	40.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:44:47.824766+00	8.09	96.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:44:57.831742+00	20.34	25.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:45:07.836881+00	7.15	40.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:45:17.841158+00	32.13	10.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:45:27.846973+00	1.18	69.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:45:37.851518+00	0.83	9.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:45:47.857951+00	11.88	76.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:45:57.861096+00	17.99	11.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:46:07.867766+00	13.72	23.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:46:17.870778+00	24.54	80.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:46:27.876664+00	18.13	69.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:46:37.877913+00	12.22	98.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:46:47.883772+00	10.0	34.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:46:57.888186+00	5.11	38.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:47:07.892503+00	0.35	89.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:47:17.895048+00	14.33	94.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:47:27.900224+00	1.73	42.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:47:37.904089+00	21.51	39.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:47:47.905661+00	9.8	16.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:47:57.910556+00	20.82	72.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:48:07.916541+00	32.94	6.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:48:17.922536+00	23.1	2.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:48:27.927134+00	25.22	24.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:48:37.932977+00	32.45	60.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:48:47.935461+00	18.19	17.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:48:57.940873+00	21.08	41.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:49:07.946957+00	31.43	56.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:49:17.949991+00	2.16	18.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:49:27.953677+00	4.43	21.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:49:37.958622+00	33.19	22.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:49:47.965261+00	10.74	65.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:49:57.966825+00	0.78	17.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:50:07.970544+00	14.69	35.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:50:17.975731+00	10.22	13.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:50:27.981702+00	21.8	86.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:50:37.982466+00	22.31	53.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:50:47.988944+00	6.44	1.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:50:57.995501+00	32.14	16.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:51:08.001543+00	19.01	12.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:51:18.006326+00	8.23	77.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:51:28.013848+00	6.19	47.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:51:38.016494+00	1.55	97.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:51:48.022228+00	0.97	41.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:51:58.023423+00	26.86	0.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:52:08.025933+00	2.67	19.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:52:18.031573+00	4.38	46.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:52:28.037202+00	21.98	74.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:52:38.042111+00	11.12	15.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:52:48.048188+00	15.77	75.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:52:58.049752+00	22.92	5.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:53:08.052916+00	29.1	31.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:53:18.059859+00	13.78	97.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:53:28.060734+00	13.18	88.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:53:38.062713+00	33.94	60.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:53:48.065658+00	19.63	49.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:53:58.069014+00	34.15	35.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:54:08.074624+00	34.0	79.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:54:18.079785+00	18.36	92.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:54:28.081062+00	33.19	8.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:54:38.087178+00	10.25	35.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:54:48.092678+00	8.4	58.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:54:58.093675+00	11.48	5.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:55:08.095887+00	22.6	50.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:55:18.099521+00	2.31	84.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:55:28.110167+00	7.0	75.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:55:38.119049+00	33.48	87.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:55:48.123482+00	14.53	66.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:55:58.128236+00	30.37	29.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:56:08.136072+00	17.68	19.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:56:18.149051+00	20.9	92.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:56:28.157691+00	19.69	18.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:56:38.164765+00	7.74	78.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:56:48.169452+00	32.49	65.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:56:58.177541+00	31.86	84.5	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:57:08.184746+00	27.94	93.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:57:18.189486+00	31.65	68.8	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:57:28.190779+00	0.87	82.1	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:57:38.194502+00	9.5	54.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:57:48.200728+00	29.69	70.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:57:58.20666+00	34.02	32.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:58:08.212298+00	29.65	25.6	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:58:18.216753+00	19.27	28.2	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:58:28.221998+00	28.44	39.0	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:58:38.226876+00	25.14	86.3	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:58:48.232492+00	23.85	79.9	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:58:58.234893+00	13.33	8.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:59:08.235798+00	21.5	92.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:59:18.240012+00	8.19	37.4	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:59:28.245895+00	17.4	21.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:59:38.250769+00	18.51	86.7	\N	\N	\N	\N	\N	\N	\N	1
craneX	2025-09-28 21:59:48.25435+00	14.46	54.2	\N	\N	\N	\N	\N	\N	\N	1
\.


--
-- Data for Name: _hyper_5_4_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_5_4_chunk (asset_id, bucket, avg_speed, avg_temperature, avg_fuel_level, avg_rpm, reading_count) FROM stdin;
craneX	2025-09-29 01:00:00+00	17.0361250000000000	45.7618750000000000	54.9243750000000000	1826.6937500000000000	160
craneX	2025-09-29 19:00:00+00	26.4400000000000000	88.2000000000000000	47.8500000000000000	2813.0000000000000000	2
craneX	2025-09-28 18:00:00+00	17.0741860465116279	43.3558139534883721	\N	\N	43
craneX	2025-09-28 20:00:00+00	17.5202941176470588	46.6552287581699346	\N	\N	306
craneX	2025-09-24 01:00:00+00	13.6665217391304348	57.4086956521739130	\N	\N	23
craneX	2025-09-28 19:00:00+00	17.5406666666666667	50.6883333333333333	\N	\N	360
craneX	2025-09-28 21:00:00+00	17.0667130919220056	51.9888579387186630	\N	\N	359
craneX	2025-09-29 18:00:00+00	20.6258823529411765	51.2147058823529412	52.3323529411764706	1907.2941176470588235	34
\.


--
-- Data for Name: _materialized_hypertable_5; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._materialized_hypertable_5 (asset_id, bucket, avg_speed, avg_temperature, avg_fuel_level, avg_rpm, reading_count) FROM stdin;
\.


--
-- Data for Name: assets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assets (id, type, location, status) FROM stdin;
1	crane	Construction Site A	active
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (job_id, asset_id, operator, status, eta) FROM stdin;
\.


--
-- Data for Name: telemetry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.telemetry (asset_id, "timestamp", speed, temperature, fuel_level, load_weight, engine_temp, coolant_temp, rpm, engine_hours, battery_v, asset_table_id) FROM stdin;
\.


--
-- Name: chunk_column_stats_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_column_stats_id_seq', 1, false);


--
-- Name: chunk_constraint_name; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_constraint_name', 5, true);


--
-- Name: chunk_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_id_seq', 4, true);


--
-- Name: continuous_agg_migrate_plan_step_step_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.continuous_agg_migrate_plan_step_step_id_seq', 1, false);


--
-- Name: dimension_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_id_seq', 5, true);


--
-- Name: dimension_slice_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_slice_id_seq', 4, true);


--
-- Name: hypertable_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.hypertable_id_seq', 5, true);


--
-- Name: bgw_job_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_config; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_config.bgw_job_id_seq', 1000, true);


--
-- Name: assets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.assets_id_seq', 1, true);


--
-- Name: jobs_job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jobs_job_id_seq', 1, false);


--
-- Name: _hyper_4_2_chunk 2_2_telemetry_pkey; Type: CONSTRAINT; Schema: _timescaledb_internal; Owner: postgres
--

ALTER TABLE ONLY _timescaledb_internal._hyper_4_2_chunk
    ADD CONSTRAINT "2_2_telemetry_pkey" PRIMARY KEY (asset_id, "timestamp");


--
-- Name: _hyper_4_3_chunk 3_3_telemetry_pkey; Type: CONSTRAINT; Schema: _timescaledb_internal; Owner: postgres
--

ALTER TABLE ONLY _timescaledb_internal._hyper_4_3_chunk
    ADD CONSTRAINT "3_3_telemetry_pkey" PRIMARY KEY (asset_id, "timestamp");


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (job_id);


--
-- Name: telemetry telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_pkey PRIMARY KEY (asset_id, "timestamp");


--
-- Name: _hyper_4_2_chunk_telemetry_timestamp_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_4_2_chunk_telemetry_timestamp_idx ON _timescaledb_internal._hyper_4_2_chunk USING btree ("timestamp" DESC);


--
-- Name: _hyper_4_3_chunk_telemetry_timestamp_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_4_3_chunk_telemetry_timestamp_idx ON _timescaledb_internal._hyper_4_3_chunk USING btree ("timestamp" DESC);


--
-- Name: _hyper_5_4_chunk__materialized_hypertable_5_asset_id_bucket_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_5_4_chunk__materialized_hypertable_5_asset_id_bucket_idx ON _timescaledb_internal._hyper_5_4_chunk USING btree (asset_id, bucket DESC);


--
-- Name: _hyper_5_4_chunk__materialized_hypertable_5_bucket_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_5_4_chunk__materialized_hypertable_5_bucket_idx ON _timescaledb_internal._hyper_5_4_chunk USING btree (bucket DESC);


--
-- Name: _materialized_hypertable_5_asset_id_bucket_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _materialized_hypertable_5_asset_id_bucket_idx ON _timescaledb_internal._materialized_hypertable_5 USING btree (asset_id, bucket DESC);


--
-- Name: _materialized_hypertable_5_bucket_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _materialized_hypertable_5_bucket_idx ON _timescaledb_internal._materialized_hypertable_5 USING btree (bucket DESC);


--
-- Name: telemetry_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX telemetry_timestamp_idx ON public.telemetry USING btree ("timestamp" DESC);


--
-- Name: _hyper_4_2_chunk ts_cagg_invalidation_trigger; Type: TRIGGER; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TRIGGER ts_cagg_invalidation_trigger AFTER INSERT OR DELETE OR UPDATE ON _timescaledb_internal._hyper_4_2_chunk FOR EACH ROW EXECUTE FUNCTION _timescaledb_functions.continuous_agg_invalidation_trigger('4');


--
-- Name: _hyper_4_3_chunk ts_cagg_invalidation_trigger; Type: TRIGGER; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TRIGGER ts_cagg_invalidation_trigger AFTER INSERT OR DELETE OR UPDATE ON _timescaledb_internal._hyper_4_3_chunk FOR EACH ROW EXECUTE FUNCTION _timescaledb_functions.continuous_agg_invalidation_trigger('4');


--
-- Name: _materialized_hypertable_5 ts_insert_blocker; Type: TRIGGER; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON _timescaledb_internal._materialized_hypertable_5 FOR EACH ROW EXECUTE FUNCTION _timescaledb_functions.insert_blocker();


--
-- Name: telemetry ts_cagg_invalidation_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_cagg_invalidation_trigger AFTER INSERT OR DELETE OR UPDATE ON public.telemetry FOR EACH ROW EXECUTE FUNCTION _timescaledb_functions.continuous_agg_invalidation_trigger('4');


--
-- Name: telemetry ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry FOR EACH ROW EXECUTE FUNCTION _timescaledb_functions.insert_blocker();


--
-- Name: _hyper_4_2_chunk 2_4_telemetry_asset_table_id_fkey; Type: FK CONSTRAINT; Schema: _timescaledb_internal; Owner: postgres
--

ALTER TABLE ONLY _timescaledb_internal._hyper_4_2_chunk
    ADD CONSTRAINT "2_4_telemetry_asset_table_id_fkey" FOREIGN KEY (asset_table_id) REFERENCES public.assets(id);


--
-- Name: _hyper_4_3_chunk 3_5_telemetry_asset_table_id_fkey; Type: FK CONSTRAINT; Schema: _timescaledb_internal; Owner: postgres
--

ALTER TABLE ONLY _timescaledb_internal._hyper_4_3_chunk
    ADD CONSTRAINT "3_5_telemetry_asset_table_id_fkey" FOREIGN KEY (asset_table_id) REFERENCES public.assets(id);


--
-- Name: jobs jobs_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id);


--
-- Name: telemetry telemetry_asset_table_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_asset_table_id_fkey FOREIGN KEY (asset_table_id) REFERENCES public.assets(id);


--
-- PostgreSQL database dump complete
--

