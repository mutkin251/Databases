-- ============================================
-- BUSINESS INTELLIGENCE QUERIES
-- Description: Key business questions answered by the DWH
-- ============================================

-- ============================================
-- Q1: Which product brings the most value?
-- ============================================
CREATE OR REPLACE VIEW `uklon_dwh.inteligance` AS
SELECT
  p.product_name,
  p.product_category,
  COUNT(DISTINCT f.order_id) AS total_orders,
  COUNT(DISTINCT f.customer_key) AS unique_customers,
  SUM(f.total_amount) AS total_revenue,
  SUM(f.uklon_commission) AS total_commission,
  AVG(f.total_amount) AS avg_order_value,
  AVG(f.customer_rating) AS avg_customer_rating,
  AVG(f.driver_rating) AS avg_driver_rating,
  SUM(f.distance_km) AS total_distance_km,
  ROUND(SUM(f.uklon_commission) / COUNT(DISTINCT f.order_id), 2) AS commission_per_order
FROM `uklon_dwh.fact_orders` f
JOIN `uklon_dwh.dim_products` p ON f.product_key = p.product_key
WHERE f.is_completed = TRUE
GROUP BY p.product_name, p.product_category
ORDER BY total_revenue DESC;

-- Query the view
SELECT * FROM `uklon_dwh.inteligance`;

-- ============================================
-- Q2: Which promo campaigns bring the most value?
-- ============================================
CREATE OR REPLACE VIEW `uklon_dwh.v_promo_campaign_effectiveness` AS
SELECT
  pc.promo_name,
  pc.promo_type,
  pc.promo_code,
  COUNT(DISTINCT pu.usage_id) AS total_usage,
  COUNT(DISTINCT pu.customer_key) AS unique_customers,
  SUM(pu.original_amount) AS total_original_amount,
  SUM(pu.discount_applied) AS total_discount_given,
  SUM(pu.final_amount) AS total_revenue_after_discount,
  AVG(pu.discount_applied) AS avg_discount_per_use,
  ROUND(SUM(pu.discount_applied) / pc.total_budget * 100, 2) AS budget_utilization_pct,
  ROUND(SUM(pu.final_amount) / SUM(pu.discount_applied), 2) AS roi_ratio,
  COUNT(CASE WHEN pu.is_first_time_use THEN 1 END) AS new_customer_acquisitions
FROM `uklon_dwh.fact_promo_usage` pu
JOIN `uklon_dwh.dim_promo_campaigns` pc ON pu.promo_key = pc.promo_key
GROUP BY pc.promo_name, pc.promo_type, pc.promo_code, pc.total_budget
ORDER BY roi_ratio DESC;

-- Query the view
SELECT * FROM `uklon_dwh.v_promo_campaign_effectiveness`;

-- ============================================
-- Q3: Revenue analysis by time period
-- ============================================
CREATE OR REPLACE VIEW `uklon_dwh.v_revenue_by_time` AS
SELECT
  dt.year,
  dt.quarter,
  dt.month,
  dt.month_name,
  dt.day_of_week_name,
  dt.time_of_day,
  dt.is_weekend,
  dt.is_peak_hours,
  COUNT(DISTINCT f.order_id) AS total_orders,
  SUM(f.total_amount) AS total_revenue,
  SUM(f.uklon_commission) AS total_commission,
  AVG(f.total_amount) AS avg_order_value,
  SUM(f.distance_km) AS total_distance
FROM `uklon_dwh.fact_orders` f
JOIN `uklon_dwh.dim_date_time` dt ON f.order_date_time_key = dt.date_time_key
WHERE f.is_completed = TRUE
GROUP BY 
  dt.year, dt.quarter, dt.month, dt.month_name, 
  dt.day_of_week_name, dt.time_of_day, dt.is_weekend, dt.is_peak_hours
ORDER BY dt.year DESC, dt.month DESC;

-- Peak hours revenue
SELECT * 
FROM `uklon_dwh.v_revenue_by_time`
WHERE is_peak_hours = TRUE
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================
-- Q4: Customer segmentation and lifetime value
-- ============================================
CREATE OR REPLACE VIEW `uklon_dwh.v_customer_lifetime_value` AS
SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  c.customer_segment,
  c.loyalty_tier,
  c.city,
  COUNT(DISTINCT f.order_id) AS total_orders,
  SUM(f.total_amount) AS lifetime_revenue,
  AVG(f.total_amount) AS avg_order_value,
  SUM(f.tips_amount) AS total_tips,
  AVG(f.customer_rating) AS avg_rating_given,
  MAX(dt.full_date) AS last_order_date,
  DATE_DIFF(CURRENT_DATE(), MAX(dt.full_date), DAY) AS days_since_last_order,
  CASE 
    WHEN DATE_DIFF(CURRENT_DATE(), MAX(dt.full_date), DAY) > 90 THEN 'At Risk'
    WHEN DATE_DIFF(CURRENT_DATE(), MAX(dt.full_date), DAY) > 30 THEN 'Inactive'
    ELSE 'Active'
  END AS customer_status
FROM `uklon_dwh.fact_orders` f
JOIN `uklon_dwh.dim_customers` c ON f.customer_key = c.customer_key AND c.is_current = TRUE
JOIN `uklon_dwh.dim_date_time` dt ON f.order_date_time_key = dt.date_time_key
WHERE f.is_completed = TRUE
GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_segment, c.loyalty_tier, c.city
ORDER BY lifetime_revenue DESC;

-- Top 20 customers by revenue
SELECT * 
FROM `uklon_dwh.v_customer_lifetime_value`
ORDER BY lifetime_revenue DESC
LIMIT 20;

-- ============================================
-- Q5: Driver performance analysis
-- ============================================
CREATE OR REPLACE VIEW `uklon_dwh.v_driver_performance` AS
SELECT
  d.driver_id,
  d.first_name,
  d.last_name,
  d.vehicle_type,
  d.city,
  COUNT(DISTINCT f.order_id) AS total_completed_rides,
  SUM(f.driver_earnings) AS total_earnings,
  AVG(f.driver_earnings) AS avg_earnings_per_ride,
  SUM(f.tips_amount) AS total_tips,
  AVG(f.driver_rating) AS avg_driver_rating,
  AVG(f.wait_time_minutes) AS avg_wait_time,
  SUM(f.distance_km) AS total_distance_driven,
  COUNT(CASE WHEN f.is_cancelled THEN 1 END) AS cancelled_rides,
  ROUND(COUNT(CASE WHEN f.is_cancelled THEN 1 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM `uklon_dwh.fact_orders` f
JOIN `uklon_dwh.dim_drivers` d ON f.driver_key = d.driver_key AND d.is_current = TRUE
GROUP BY d.driver_id, d.first_name, d.last_name, d.vehicle_type, d.city
ORDER BY total_earnings DESC;

-- Top performing drivers
SELECT * 
FROM `uklon_dwh.v_driver_performance`
WHERE avg_driver_rating >= 4.5
ORDER BY total_earnings DESC
LIMIT 20;

-- ============================================
-- Q6: Geographic analysis - High demand areas
-- ============================================
CREATE OR REPLACE VIEW `uklon_dwh.v_location_demand` AS
SELECT
  l.city,
  l.district,
  l.zone_name,
  l.location_type,
  COUNT(DISTINCT f.order_id) AS total_pickups,
  SUM(f.total_amount) AS total_revenue,
  AVG(f.wait_time_minutes) AS avg_wait_time,
  AVG(f.surge_multiplier) AS avg_surge_multiplier,
  COUNT(CASE WHEN f.is_surge_pricing THEN 1 END) AS surge_pricing_count
FROM `uklon_dwh.fact_orders` f
JOIN `uklon_dwh.dim_location` l ON f.pickup_location_key = l.location_key
WHERE f.is_completed = TRUE
GROUP BY l.city, l.district, l.zone_name, l.location_type
ORDER BY total_pickups DESC;

-- High demand zones
SELECT * 
FROM `uklon_dwh.v_location_demand`
ORDER BY total_pickups DESC
LIMIT 20;

-- ============================================
-- Q7: Payment method analysis
-- ============================================
SELECT
  f.payment_method,
  COUNT(DISTINCT f.order_id) AS total_orders,
  SUM(f.total_amount) AS total_revenue,
  AVG(f.total_amount) AS avg_transaction_value,
  COUNT(CASE WHEN fp.is_successful THEN 1 END) AS successful_payments,
  COUNT(CASE WHEN NOT fp.is_successful THEN 1 END) AS failed_payments,
  ROUND(COUNT(CASE WHEN fp.is_successful THEN 1 END) * 100.0 / COUNT(*), 2) AS success_rate_pct
FROM `uklon_dwh.fact_orders` f
LEFT JOIN `uklon_dwh.fact_payments` fp ON f.order_fact_key = fp.order_fact_key
WHERE f.is_completed = TRUE
GROUP BY f.payment_method
ORDER BY total_revenue DESC;

-- ============================================
-- Q8: Cancellation analysis
-- ============================================
SELECT
  dt.day_of_week_name,
  dt.time_of_day,
  f.order_status,
  f.cancellation_reason,
  COUNT(DISTINCT f.order_id) AS total_cancellations,
  AVG(f.wait_time_minutes) AS avg_wait_time_before_cancel
FROM `uklon_dwh.fact_orders` f
JOIN `uklon_dwh.dim_date_time` dt ON f.order_date_time_key = dt.date_time_key
WHERE f.is_cancelled = TRUE
GROUP BY dt.day_of_week_name, dt.time_of_day, f.order_status, f.cancellation_reason
ORDER BY total_cancellations DESC;

-- ============================================
-- Q9: Monthly growth metrics
-- ============================================
WITH monthly_metrics AS (
  SELECT
    dt.year,
    dt.month,
    dt.month_name,
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(DISTINCT f.customer_key) AS active_customers,
    SUM(f.total_amount) AS revenue,
    SUM(f.uklon_commission) AS commission
  FROM `uklon_dwh.fact_orders` f
  JOIN `uklon_dwh.dim_date_time` dt ON f.order_date_time_key = dt.date_time_key
  WHERE f.is_completed = TRUE
  GROUP BY dt.year, dt.month, dt.month_name
)
SELECT
  year,
  month,
  month_name,
  total_orders,
  active_customers,
  revenue,
  commission,
  LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
  ROUND((revenue - LAG(revenue) OVER (ORDER BY year, month)) / 
        LAG(revenue) OVER (ORDER BY year, month) * 100, 2) AS revenue_growth_pct,
  ROUND((total_orders - LAG(total_orders) OVER (ORDER BY year, month)) / 
        LAG(total_orders) OVER (ORDER BY year, month) * 100, 2) AS order_growth_pct
FROM monthly_metrics
ORDER BY year DESC, month DESC;