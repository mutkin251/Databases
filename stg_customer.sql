-- ============================================
-- ETL LAYER 1: Source to Staging
-- Description: Load data from OLTP/source systems to staging
-- ============================================

-- Create staging schema
-- Staging tables mirror source structure

-- STAGING: Customers from jaffle_shop
CREATE OR REPLACE TABLE `uklon_staging.stg_customers` AS
SELECT
  id AS customer_id,
  first_name,
  last_name,
  email,
  phone_number AS phone,
  registration_date,
  city,
  'Ukraine' AS country,
  CASE 
    WHEN total_orders >= 50 THEN 'VIP'
    WHEN total_orders >= 10 THEN 'Regular'
    ELSE 'New'
  END AS customer_segment,
  CASE
    WHEN total_amount >= 10000 THEN 'Gold'
    WHEN total_amount >= 5000 THEN 'Silver'
    ELSE 'Bronze'
  END AS loyalty_tier,
  total_orders AS total_lifetime_rides,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `jaffle_shop.customers`;

-- STAGING: Drivers (assuming similar structure)
CREATE OR REPLACE TABLE `uklon_staging.stg_drivers` AS
SELECT
  driver_id,
  first_name,
  last_name,
  email,
  phone,
  license_number,
  license_expiry_date,
  vehicle_type,
  vehicle_make,
  vehicle_model,
  vehicle_year,
  vehicle_color,
  vehicle_plate_number,
  onboarding_date,
  status AS driver_status,
  average_rating,
  total_completed_rides,
  city,
  'Ukraine' AS country,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `source_system.drivers`;

-- STAGING: Orders from jaffle_shop
CREATE OR REPLACE TABLE `uklon_staging.stg_orders` AS
SELECT
  order_id,
  customer_id,
  driver_id,
  product_id,
  promo_code,
  order_datetime,
  pickup_datetime,
  dropoff_datetime,
  pickup_location_id,
  dropoff_location_id,
  order_status,
  cancellation_reason,
  payment_method,
  distance_km,
  estimated_duration_minutes,
  actual_duration_minutes,
  wait_time_minutes,
  base_fare,
  distance_fare,
  time_fare,
  surge_multiplier,
  surge_amount,
  subtotal_amount,
  discount_amount,
  promo_discount,
  service_fee,
  total_amount,
  driver_earnings,
  commission AS uklon_commission,
  tips_amount,
  customer_rating,
  driver_rating,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `jaffle_shop.orders`;

-- STAGING: Payments from stripe
CREATE OR REPLACE TABLE `uklon_staging.stg_payments` AS
SELECT
  payment_id,
  order_id,
  customer_id,
  payment_datetime,
  payment_method,
  payment_status,
  payment_gateway,
  transaction_reference,
  amount AS payment_amount,
  processing_fee,
  net_amount,
  refund_amount,
  currency_code,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `stripe.payment`;

-- STAGING: Promo campaigns
CREATE OR REPLACE TABLE `uklon_staging.stg_promo_campaigns` AS
SELECT
  promo_id,
  promo_code,
  promo_name,
  promo_type,
  discount_value,
  discount_percentage,
  max_discount_amount,
  min_order_amount,
  campaign_start_date,
  campaign_end_date,
  target_segment,
  usage_limit_per_user,
  total_budget,
  campaign_status,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `source_system.promo_campaigns`;

-- STAGING: Products/Services
CREATE OR REPLACE TABLE `uklon_staging.stg_products` AS
SELECT
  product_id,
  product_name,
  product_category,
  base_price,
  price_per_km,
  price_per_minute,
  commission_rate,
  is_active,
  description,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `source_system.products`;

-- STAGING: Locations
CREATE OR REPLACE TABLE `uklon_staging.stg_locations` AS
SELECT
  location_id,
  latitude,
  longitude,
  address,
  district,
  city,
  region,
  country,
  postal_code,
  location_type,
  is_high_demand_area,
  zone_name,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `source_system.locations`;