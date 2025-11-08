-- ============================================
-- DIMENSION TABLE: dim_location
-- Description: Location dimension for pickup and dropoff
-- ============================================

CREATE TABLE IF NOT EXISTS `uklon_dwh.dim_location` (
  -- Surrogate Key
  location_key INT64 NOT NULL,
  
  -- Business Key
  location_id STRING NOT NULL,
  
  -- Attributes
  latitude NUMERIC(10,8),
  longitude NUMERIC(11,8),
  address STRING,
  district STRING,
  city STRING NOT NULL,
  region STRING,
  country STRING NOT NULL,
  postal_code STRING,
  location_type STRING, -- Residential, Commercial, Airport, Train Station, etc.
  is_high_demand_area BOOL,
  zone_name STRING, -- For surge pricing zones
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY city, location_id
OPTIONS(
  description = "Location dimension for pickup and dropoff locations"
);