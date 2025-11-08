-- ============================================
-- FACT TABLE: fact_orders
-- Description: Main fact table for ride orders
-- ============================================

CREATE TABLE IF NOT EXISTS `uklon_dwh.fact_orders` (
  -- Surrogate Key
  order_fact_key INT64 NOT NULL,
  
  -- Business Key
  order_id STRING NOT NULL,
  
  -- Foreign Keys (Dimensions)
  customer_key INT64,
  driver_key INT64,
  product_key INT64,
  promo_key INT64,
  pickup_location_key INT64,
  dropoff_location_key INT64,
  order_date_time_key INT64,
  pickup_date_time_key INT64,
  dropoff_date_time_key INT64,
  
  -- Degenerate Dimensions (attributes that don't warrant separate dimension)
  order_status STRING, -- Requested, Accepted, In Progress, Completed, Cancelled
  cancellation_reason STRING,
  payment_method STRING, -- Cash, Card, Apple Pay, Google Pay
  
  -- Measures (Numeric Facts)
  -- Distance and Duration
  distance_km NUMERIC(10,2),
  estimated_duration_minutes INT64,
  actual_duration_minutes INT64,
  wait_time_minutes INT64,
  
  -- Financial Measures
  base_fare NUMERIC(10,2),
  distance_fare NUMERIC(10,2),
  time_fare NUMERIC(10,2),
  surge_multiplier NUMERIC(5,2),
  surge_amount NUMERIC(10,2),
  subtotal_amount NUMERIC(10,2),
  discount_amount NUMERIC(10,2),
  promo_discount NUMERIC(10,2),
  service_fee NUMERIC(10,2),
  total_amount NUMERIC(10,2),
  driver_earnings NUMERIC(10,2),
  uklon_commission NUMERIC(10,2),
  tips_amount NUMERIC(10,2),
  
  -- Quality Measures
  customer_rating NUMERIC(2,1),
  driver_rating NUMERIC(2,1),
  
  -- Flags
  is_completed BOOL,
  is_cancelled BOOL,
  is_surge_pricing BOOL,
  is_first_ride BOOL,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY DATE(created_at)
CLUSTER BY customer_key, driver_key, product_key
OPTIONS(
  description = "Main fact table containing all ride order transactions"
);

-- Indexes for common queries
CREATE OR REPLACE VIEW `uklon_dwh.v_fact_orders_completed` AS
SELECT *
FROM `uklon_dwh.fact_orders`
WHERE is_completed = TRUE;