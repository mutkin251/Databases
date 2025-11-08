-- ============================================
-- FACT TABLE: fact_payments
-- Description: Payment transactions fact table
-- ============================================

CREATE TABLE IF NOT EXISTS `uklon_dwh.fact_payments` (
  -- Surrogate Key
  payment_fact_key INT64 NOT NULL,
  
  -- Business Key
  payment_id STRING NOT NULL,
  
  -- Foreign Keys
  order_fact_key INT64,
  customer_key INT64,
  payment_date_time_key INT64,
  
  -- Degenerate Dimensions
  payment_method STRING, -- Cash, Card, Wallet, Apple Pay, Google Pay
  payment_status STRING, -- Pending, Completed, Failed, Refunded
  payment_gateway STRING, -- Stripe, PayPal, etc.
  transaction_reference STRING,
  currency_code STRING DEFAULT 'UAH',
  
  -- Measures
  payment_amount NUMERIC(10,2),
  processing_fee NUMERIC(10,2),
  net_amount NUMERIC(10,2),
  refund_amount NUMERIC(10,2),
  
  -- Flags
  is_successful BOOL,
  is_refunded BOOL,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY DATE(created_at)
CLUSTER BY customer_key, payment_status
OPTIONS(
  description = "Payment transactions fact table"
);