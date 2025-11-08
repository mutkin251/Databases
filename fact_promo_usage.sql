-- ============================================
-- FACT TABLE: fact_promo_usage
-- Description: Promo campaign usage tracking
-- ============================================

CREATE TABLE IF NOT EXISTS `uklon_dwh.fact_promo_usage` (
  -- Surrogate Key
  promo_usage_key INT64 NOT NULL,
  
  -- Business Key
  usage_id STRING NOT NULL,
  
  -- Foreign Keys
  order_fact_key INT64,
  promo_key INT64 NOT NULL,
  customer_key INT64 NOT NULL,
  usage_date_time_key INT64,
  
  -- Degenerate Dimensions
  usage_status STRING, -- Applied, Expired, Invalid
  
  -- Measures
  original_amount NUMERIC(10,2),
  discount_applied NUMERIC(10,2),
  final_amount NUMERIC(10,2),
  
  -- Flags
  is_first_time_use BOOL,
  is_successful BOOL,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY DATE(created_at)
CLUSTER BY promo_key, customer_key
OPTIONS(
  description = "Tracks promotional campaign usage and effectiveness"
);