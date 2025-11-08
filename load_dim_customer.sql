-- ============================================
-- ETL LAYER 2: Staging to Dimensions (SCD Type 2)
-- Description: Load staging data into dimension tables
-- ============================================

-- ============================================
-- DIMENSION: load_dim_customers (SCD Type 2)
-- ============================================
CREATE OR REPLACE PROCEDURE `uklon_dwh.load_load_dim_customers`()
BEGIN
  -- Handle SCD Type 2: Expire changed records
  UPDATE `uklon_dwh.load_load_dim_customers` AS dim
  SET 
    expiration_date = CURRENT_TIMESTAMP(),
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP()
  WHERE dim.is_current = TRUE
    AND EXISTS (
      SELECT 1
      FROM `uklon_staging.stg_customers` AS stg
      WHERE stg.customer_id = dim.customer_id
        AND (
          stg.email != dim.email OR
          stg.phone != dim.phone OR
          stg.customer_segment != dim.customer_segment OR
          stg.loyalty_tier != dim.loyalty_tier OR
          stg.city != dim.city
        )
    );
  
  -- Insert new and changed records
  INSERT INTO `uklon_dwh.load_dim_customers`
  SELECT
    -- Generate surrogate key
    ROW_NUMBER() OVER (ORDER BY stg.customer_id) + 
      COALESCE((SELECT MAX(customer_key) FROM `uklon_dwh.load_dim_customers`), 0) AS customer_key,
    stg.customer_id,
    stg.first_name,
    stg.last_name,
    stg.email,
    stg.phone,
    stg.registration_date,
    stg.customer_segment,
    stg.loyalty_tier,
    stg.total_lifetime_rides,
    stg.city,
    stg.country,
    CURRENT_TIMESTAMP() AS effective_date,
    NULL AS expiration_date,
    TRUE AS is_current,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
  FROM `uklon_staging.stg_customers` AS stg
  WHERE NOT EXISTS (
    SELECT 1
    FROM `uklon_dwh.load_dim_customers` AS dim
    WHERE dim.customer_id = stg.customer_id
      AND dim.is_current = TRUE
  );
END;

-- ============================================
-- DIMENSION: dim_drivers (SCD Type 2)
-- ============================================
CREATE OR REPLACE PROCEDURE `uklon_dwh.load_dim_drivers`()
BEGIN
  -- Expire changed records
  UPDATE `uklon_dwh.dim_drivers` AS dim
  SET 
    expiration_date = CURRENT_TIMESTAMP(),
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP()
  WHERE dim.is_current = TRUE
    AND EXISTS (
      SELECT 1
      FROM `uklon_staging.stg_drivers` AS stg
      WHERE stg.driver_id = dim.driver_id
        AND (
          stg.vehicle_type != dim.vehicle_type OR
          stg.vehicle_plate_number != dim.vehicle_plate_number OR
          stg.driver_status != dim.driver_status OR
          stg.average_rating != dim.average_rating
        )
    );
  
  -- Insert new and changed records
  INSERT INTO `uklon_dwh.dim_drivers`
  SELECT
    ROW_NUMBER() OVER (ORDER BY stg.driver_id) + 
      COALESCE((SELECT MAX(driver_key) FROM `uklon_dwh.dim_drivers`), 0) AS driver_key,
    stg.driver_id,
    stg.first_name,
    stg.last_name,
    stg.email,
    stg.phone,
    stg.license_number,
    stg.license_expiry_date,
    stg.vehicle_type,
    stg.vehicle_make,
    stg.vehicle_model,
    stg.vehicle_year,
    stg.vehicle_color,
    stg.vehicle_plate_number,
    stg.onboarding_date,
    stg.driver_status,
    stg.average_rating,
    stg.total_completed_rides,
    stg.city,
    stg.country,
    CURRENT_TIMESTAMP() AS effective_date,
    NULL AS expiration_date,
    TRUE AS is_current,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
  FROM `uklon_staging.stg_drivers` AS stg
  WHERE NOT EXISTS (
    SELECT 1
    FROM `uklon_dwh.dim_drivers` AS dim
    WHERE dim.driver_id = stg.driver_id
      AND dim.is_current = TRUE
  );
END;

-- ============================================
-- DIMENSION: dim_products (SCD Type 2)
-- ============================================
CREATE OR REPLACE PROCEDURE `uklon_dwh.load_dim_products`()
BEGIN
  UPDATE `uklon_dwh.dim_products` AS dim
  SET 
    expiration_date = CURRENT_TIMESTAMP(),
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP()
  WHERE dim.is_current = TRUE
    AND EXISTS (
      SELECT 1
      FROM `uklon_staging.stg_products` AS stg
      WHERE stg.product_id = dim.product_id
        AND (
          stg.base_price != dim.base_price OR
          stg.price_per_km != dim.price_per_km OR
          stg.commission_rate != dim.commission_rate
        )
    );
  
  INSERT INTO `uklon_dwh.dim_products`
  SELECT
    ROW_NUMBER() OVER (ORDER BY stg.product_id) + 
      COALESCE((SELECT MAX(product_key) FROM `uklon_dwh.dim_products`), 0) AS product_key,
    stg.product_id,
    stg.product_name,
    stg.product_category,
    stg.base_price,
    stg.price_per_km,
    stg.price_per_minute,
    stg.commission_rate,
    stg.is_active,
    stg.description,
    CURRENT_TIMESTAMP() AS effective_date,
    NULL AS expiration_date,
    TRUE AS is_current,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
  FROM `uklon_staging.stg_products` AS stg
  WHERE NOT EXISTS (
    SELECT 1
    FROM `uklon_dwh.dim_products` AS dim
    WHERE dim.product_id = stg.product_id
      AND dim.is_current = TRUE
  );
END;

-- ============================================
-- DIMENSION: dim_promo_campaigns (SCD Type 2)
-- ============================================
CREATE OR REPLACE PROCEDURE `uklon_dwh.load_dim_promo_campaigns`()
BEGIN
  UPDATE `uklon_dwh.dim_promo_campaigns` AS dim
  SET 
    expiration_date = CURRENT_TIMESTAMP(),
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP()
  WHERE dim.is_current = TRUE
    AND EXISTS (
      SELECT 1
      FROM `uklon_staging.stg_promo_campaigns` AS stg
      WHERE stg.promo_id = dim.promo_id
        AND stg.campaign_status != dim.campaign_status
    );
  
  INSERT INTO `uklon_dwh.dim_promo_campaigns`
  SELECT
    ROW_NUMBER() OVER (ORDER BY stg.promo_id) + 
      COALESCE((SELECT MAX(promo_key) FROM `uklon_dwh.dim_promo_campaigns`), 0) AS promo_key,
    stg.promo_id,
    stg.promo_code,
    stg.promo_name,
    stg.promo_type,
    stg.discount_value,
    stg.discount_percentage,
    stg.max_discount_amount,
    stg.min_order_amount,
    stg.campaign_start_date,
    stg.campaign_end_date,
    stg.target_segment,
    stg.usage_limit_per_user,
    stg.total_budget,
    stg.campaign_status,
    CURRENT_TIMESTAMP() AS effective_date,
    NULL AS expiration_date,
    TRUE AS is_current,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
  FROM `uklon_staging.stg_promo_campaigns` AS stg
  WHERE NOT EXISTS (
    SELECT 1
    FROM `uklon_dwh.dim_promo_campaigns` AS dim
    WHERE dim.promo_id = stg.promo_id
      AND dim.is_current = TRUE
  );
END;

-- ============================================
-- DIMENSION: dim_location (Type 1 - No history)
-- ============================================
CREATE OR REPLACE PROCEDURE `uklon_dwh.load_dim_location`()
BEGIN
  MERGE `uklon_dwh.dim_location` AS target
  USING `uklon_staging.stg_locations` AS source
  ON target.location_id = source.location_id
  WHEN MATCHED THEN
    UPDATE SET
      latitude = source.latitude,
      longitude = source.longitude,
      address = source.address,
      district = source.district,
      city = source.city,
      region = source.region,
      country = source.country,
      postal_code = source.postal_code,
      location_type = source.location_type,
      is_high_demand_area = source.is_high_demand_area,
      zone_name = source.zone_name,
      updated_at = CURRENT_TIMESTAMP()
  WHEN NOT MATCHED THEN
    INSERT (
      location_key,
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
      created_at,
      updated_at
    )
    VALUES (
      (SELECT COALESCE(MAX(location_key), 0) + ROW_NUMBER() OVER (ORDER BY source.location_id) 
       FROM `uklon_dwh.dim_location`),
      source.location_id,
      source.latitude,
      source.longitude,
      source.address,
      source.district,
      source.city,
      source.region,
      source.country,
      source.postal_code,
      source.location_type,
      source.is_high_demand_area,
      source.zone_name,
      CURRENT_TIMESTAMP(),
      CURRENT_TIMESTAMP()
    );
END;