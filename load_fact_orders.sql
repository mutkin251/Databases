-- ============================================
-- ETL LAYER 3: Staging to Fact Tables
-- Description: Load staging data into fact tables with proper FK lookups
-- ============================================

-- ============================================
-- FACT: fact_orders
-- ============================================
CREATE OR REPLACE PROCEDURE `uklon_dwh.load_fact_orders`()
BEGIN
  INSERT INTO `uklon_dwh.fact_orders`
  SELECT
    -- Generate fact key
    ROW_NUMBER() OVER (ORDER BY stg.order_id) + 
      COALESCE((SELECT MAX(order_fact_key) FROM `uklon_dwh.fact_orders`), 0) AS order_fact_key,
    
    stg.order_id,
    
    -- FK Lookups
    dc.customer_key,
    dd.driver_key,
    dp.product_key,
    dpc.promo_key,
    dlp.location_key AS pickup_location_key,
    dld.location_key AS dropoff_location_key,
    dto.date_time_key AS order_date_time_key,
    dtp.date_time_key AS pickup_date_time_key,
    dtd.date_time_key AS dropoff_date_time_key,
    
    -- Degenerate dimensions
    stg.order_status,
    stg.cancellation_reason,
    stg.payment_method,
    
    -- Measures
    stg.distance_km,
    stg.estimated_duration_minutes,
    stg.actual_duration_minutes,
    stg.wait_time_minutes,
    stg.base_fare,
    stg.distance_fare,
    stg.time_fare,
    stg.surge_multiplier,
    stg.surge_amount,
    stg.subtotal_amount,
    stg.discount_amount,
    stg.promo_discount,
    stg.service_fee,
    stg.total_amount,
    stg.driver_earnings,
    stg.uklon_commission,
    stg.tips_amount,
    stg.customer_rating,
    stg.driver_rating,
    
    -- Flags
    CASE WHEN stg.order_status = 'Completed' THEN TRUE ELSE FALSE END AS is_completed,
    CASE WHEN stg.order_status = 'Cancelled' THEN TRUE ELSE FALSE END AS is_cancelled,
    CASE WHEN stg.surge_multiplier > 1 THEN TRUE ELSE FALSE END AS is_surge_pricing,
    CASE WHEN dc.total_lifetime_rides = 1 THEN TRUE ELSE FALSE END AS is_first_ride,
    
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
    
  FROM `uklon_staging.stg_orders` AS stg
  
  -- Join with dimensions to get surrogate keys
  LEFT JOIN `uklon_dwh.dim_customers` AS dc
    ON stg.customer_id = dc.customer_id 
    AND dc.is_current = TRUE
    
  LEFT JOIN `uklon_dwh.dim_drivers` AS dd
    ON stg.driver_id = dd.driver_id 
    AND dd.is_current = TRUE
    
  LEFT JOIN `uklon_dwh.dim_products` AS dp
    ON stg.product_id = dp.product_id 
    AND dp.is_current = TRUE
    
  LEFT JOIN `uklon_dwh.dim_promo_campaigns` AS dpc
    ON stg.promo_code = dpc.promo_code 
    AND dpc.is_current = TRUE
    
  LEFT JOIN `uklon_dwh.dim_location` AS dlp
    ON stg.pickup_location_id = dlp.location_id
    
  LEFT JOIN `uklon_dwh.dim_location` AS dld
    ON stg.dropoff_location_id = dld.location_id
    
  -- Date/Time dimension lookups
  LEFT JOIN `uklon_dwh.dim_date_time` AS dto
    ON DATE(stg.order_datetime) = dto.full_date
    AND EXTRACT(HOUR FROM stg.order_datetime) = dto.hour
    AND EXTRACT(MINUTE FROM stg.order_datetime) = dto.minute
    
  LEFT JOIN `uklon_dwh.dim_date_time` AS dtp
    ON DATE(stg.pickup_datetime) = dtp.full_date
    AND EXTRACT(HOUR FROM stg.pickup_datetime) = dtp.hour
    AND EXTRACT(MINUTE FROM stg.pickup_datetime) = dtp.minute
    
  LEFT JOIN `uklon_dwh.dim_date_time` AS dtd
    ON DATE(stg.dropoff_datetime) = dtd.full_date
    AND EXTRACT(HOUR FROM stg.dropoff_datetime) = dtd.hour
    AND EXTRACT(MINUTE FROM stg.dropoff_datetime) = dtd.minute
    
  WHERE NOT EXISTS (
    SELECT 1 
    FROM `uklon_dwh.fact_orders` AS fo
    WHERE fo.order_id = stg.order_id
  );
END;

-- ============================================
-- FACT: fact_payments
-- ============================================
CREATE OR REPLACE PROCEDURE `uklon_dwh.load_fact_payments`()
BEGIN
  INSERT INTO `uklon_dwh.fact_payments`
  SELECT
    ROW_NUMBER() OVER (ORDER BY stg.payment_id) + 
      COALESCE((SELECT MAX(payment_fact_key) FROM `uklon_dwh.fact_payments`), 0) AS payment_fact_key,
    
    stg.payment_id,
    fo.order_fact_key,
    dc.customer_key,
    dt.date_time_key AS payment_date_time_key,
    
    stg.payment_method,
    stg.payment_status,
    stg.payment_gateway,
    stg.transaction_reference,
    stg.currency_code,
    
    stg.payment_amount,
    stg.processing_fee,
    stg.net_amount,
    stg.refund_amount,
    
    CASE WHEN stg.payment_status = 'Completed' THEN TRUE ELSE FALSE END AS is_successful,
    CASE WHEN stg.refund_amount > 0 THEN TRUE ELSE FALSE END AS is_refunded,
    
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
    
  FROM `uklon_staging.stg_payments` AS stg
  
  LEFT JOIN `uklon_dwh.fact_orders` AS fo
    ON stg.order_id = fo.order_id
    
  LEFT JOIN `uklon_dwh.dim_customers` AS dc
    ON stg.customer_id = dc.customer_id 
    AND dc.is_current = TRUE
    
  LEFT JOIN `uklon_dwh.dim_date_time` AS dt
    ON DATE(stg.payment_datetime) = dt.full_date
    AND EXTRACT(HOUR FROM stg.payment_datetime) = dt.hour
    AND EXTRACT(MINUTE FROM stg.payment_datetime) = dt.minute
    
  WHERE NOT EXISTS (
    SELECT 1 
    FROM `uklon_dwh.fact_payments` AS fp
    WHERE fp.payment_id = stg.payment_id
  );
END;

-- ============================================
-- FACT: fact_promo_usage
-- ============================================
CREATE OR REPLACE PROCEDURE `uklon_dwh.load_fact_promo_usage`()
BEGIN
  INSERT INTO `uklon_dwh.fact_promo_usage`
  SELECT
    ROW_NUMBER() OVER (ORDER BY fo.order_id) + 
      COALESCE((SELECT MAX(promo_usage_key) FROM `uklon_dwh.fact_promo_usage`), 0) AS promo_usage_key,
    
    CONCAT('PU-', fo.order_id) AS usage_id,
    fo.order_fact_key,
    fo.promo_key,
    fo.customer_key,
    fo.order_date_time_key AS usage_date_time_key,
    
    CASE 
      WHEN fo.promo_discount > 0 THEN 'Applied'
      ELSE 'Invalid'
    END AS usage_status,
    
    fo.subtotal_amount AS original_amount,
    fo.promo_discount AS discount_applied,
    fo.total_amount AS final_amount,
    
    fo.is_first_ride AS is_first_time_use,
    CASE WHEN fo.promo_discount > 0 THEN TRUE ELSE FALSE END AS is_successful,
    
    CURRENT_TIMESTAMP() AS created_at
    
  FROM `uklon_dwh.fact_orders` AS fo
  WHERE fo.promo_key IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 
      FROM `uklon_dwh.fact_promo_usage` AS fpu
      WHERE fpu.order_fact_key = fo.order_fact_key
    );
END;

-- ============================================
-- Master ETL Orchestration Procedure
-- ============================================
CREATE OR REPLACE PROCEDURE `uklon_dwh.run_full_etl`()
BEGIN
  -- Step 1: Load Dimensions (order matters due to FK dependencies)
  CALL `uklon_dwh.populate_dim_date_time`();
  CALL `uklon_dwh.load_dim_customers`();
  CALL `uklon_dwh.load_dim_drivers`();
  CALL `uklon_dwh.load_dim_products`();
  CALL `uklon_dwh.load_dim_promo_campaigns`();
  CALL `uklon_dwh.load_dim_location`();
  
  -- Step 2: Load Facts
  CALL `uklon_dwh.load_fact_orders`();
  CALL `uklon_dwh.load_fact_payments`();
  CALL `uklon_dwh.load_fact_promo_usage`();
  
  -- Log completion
  SELECT 'ETL completed successfully' AS status, CURRENT_TIMESTAMP() AS completed_at;
END;