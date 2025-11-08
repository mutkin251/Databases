-- ============================================
-- DIMENSION TABLE: dim_customers
-- Description: Customer dimension with SCD Type 2
-- ============================================

CREATE TABLE IF NOT EXISTS `uklon_dwh.dim_customers` (
  -- Surrogate Key
  customer_key INT64 NOT NULL,
  
  -- Business Key
  customer_id STRING NOT NULL,
  
  -- Attributes
  first_name STRING,
  last_name STRING,
  email STRING,
  phone STRING,
  registration_date DATE,
  customer_segment STRING, -- VIP, Regular, New
  loyalty_tier STRING, -- Gold, Silver, Bronze
  total_lifetime_rides INT64,
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
CLUSTER BY customer_id, is_current
OPTIONS(
  description = "Customer dimension table with SCD Type 2 for tracking historical changes"
);

-- Create indexes for better performance
CREATE OR REPLACE VIEW `uklon_dwh.v_dim_customers_current` AS
SELECT *
FROM `uklon_dwh.dim_customers`
WHERE is_current = TRUE;