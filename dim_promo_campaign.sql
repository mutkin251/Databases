-- ============================================
-- DIMENSION TABLE: dim_promo_campaigns
-- Description: Promotional campaigns dimension
-- ============================================

CREATE TABLE IF NOT EXISTS `uklon_dwh.dim_promo_campaigns` (
  -- Surrogate Key
  promo_key INT64 NOT NULL,
  
  -- Business Key
  promo_id STRING NOT NULL,
  
  -- Attributes
  promo_code STRING,
  promo_name STRING NOT NULL,
  promo_type STRING, -- Percentage Discount, Fixed Amount, Free Ride, Cashback
  discount_value NUMERIC(10,2),
  discount_percentage NUMERIC(5,2),
  max_discount_amount NUMERIC(10,2),
  min_order_amount NUMERIC(10,2),
  campaign_start_date DATE,
  campaign_end_date DATE,
  target_segment STRING, -- New Users, All Users, VIP, Specific City
  usage_limit_per_user INT64,
  total_budget NUMERIC(12,2),
  campaign_status STRING, -- Active, Expired, Paused
  
  -- SCD Type 2 Fields
  effective_date TIMESTAMP NOT NULL,
  expiration_date TIMESTAMP,
  is_current BOOL NOT NULL,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY promo_id, is_current
OPTIONS(
  description = "Promotional campaigns dimension"
);

-- Current promos view
CREATE OR REPLACE VIEW `uklon_dwh.v_dim_promo_campaigns_current` AS
SELECT *
FROM `uklon_dwh.dim_promo_campaigns`
WHERE is_current = TRUE;