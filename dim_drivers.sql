-- ============================================
-- DIMENSION TABLE: dim_drivers
-- Description: Driver dimension with SCD Type 2
-- ============================================

CREATE TABLE IF NOT EXISTS `uklon_dwh.dim_drivers` (
  -- Surrogate Key
  driver_key INT64 NOT NULL,
  
  -- Business Key
  driver_id STRING NOT NULL,
  
  -- Attributes
  first_name STRING,
  last_name STRING,
  email STRING,
  phone STRING,
  license_number STRING,
  license_expiry_date DATE,
  vehicle_type STRING, -- Economy, Comfort, Business
  vehicle_make STRING,
  vehicle_model STRING,
  vehicle_year INT64,
  vehicle_color STRING,
  vehicle_plate_number STRING,
  onboarding_date DATE,
  driver_status STRING, -- Active, Inactive, Suspended
  average_rating NUMERIC(3,2),
  total_completed_rides INT64,
  city STRING,
  country STRING,
  
  -- SCD Type 2 Fields
  effective_date TIMESTAMP NOT NULL,
  expiration_date TIMESTAMP,
  is_current BOOL NOT NULL,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY DATE(effective_date)
CLUSTER BY driver_id, is_current
OPTIONS(
  description = "Driver dimension table with SCD Type 2 for tracking historical changes"
);

-- Current drivers view
CREATE OR REPLACE VIEW `uklon_dwh.v_dim_drivers_current` AS
SELECT *
FROM `uklon_dwh.dim_drivers`
WHERE is_current = TRUE;