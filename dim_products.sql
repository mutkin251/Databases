-- ============================================
-- DIMENSION TABLE: dim_products
-- Description: Product/Ride type dimension
-- ============================================

CREATE TABLE IF NOT EXISTS `uklon_dwh.dim_products` (
  -- Surrogate Key
  product_key INT64 NOT NULL,
  
  -- Business Key
  product_id STRING NOT NULL,
  
  -- Attributes
  product_name STRING NOT NULL, -- Uklon Economy, Uklon Comfort, Uklon Business, Uklon XL
  product_category STRING, -- Standard Ride, Premium Ride, Shared Ride
  base_price NUMERIC(10,2),
  price_per_km NUMERIC(10,2),
  price_per_minute NUMERIC(10,2),
  commission_rate NUMERIC(5,2), -- % commission Uklon takes
  is_active BOOL,
  description STRING,
  
  -- SCD Type 2 Fields
  effective_date TIMESTAMP NOT NULL,
  expiration_date TIMESTAMP,
  is_current BOOL NOT NULL,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY product_id, is_current
OPTIONS(
  description = "Product dimension for different ride types"
);

-- Current products view
CREATE OR REPLACE VIEW `uklon_dwh.v_dim_products_current` AS
SELECT *
FROM `uklon_dwh.dim_products`
WHERE is_current = TRUE;