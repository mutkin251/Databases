-- ============================================
-- DIMENSION TABLE: dim_date_time
-- Description: Date and time dimension for temporal analysis
-- ============================================

CREATE TABLE IF NOT EXISTS `uklon_dwh.dim_date_time` (
  -- Surrogate Key
  date_time_key INT64 NOT NULL,
  
  -- Date attributes
  full_date DATE NOT NULL,
  date_string STRING, -- YYYY-MM-DD
  year INT64,
  quarter INT64,
  month INT64,
  month_name STRING,
  week_of_year INT64,
  day_of_month INT64,
  day_of_week INT64,
  day_of_week_name STRING,
  is_weekend BOOL,
  is_holiday BOOL,
  holiday_name STRING,
  
  -- Time attributes
  hour INT64,
  minute INT64,
  time_of_day STRING, -- Morning, Afternoon, Evening, Night
  is_business_hours BOOL, -- 9 AM - 6 PM
  is_peak_hours BOOL, -- 7-9 AM, 5-8 PM
  
  -- Fiscal attributes
  fiscal_year INT64,
  fiscal_quarter INT64,
  fiscal_month INT64
)
CLUSTER BY full_date
OPTIONS(
  description = "Date and time dimension for temporal analysis"
);

-- Generate date dimension data (example for 5 years)
CREATE OR REPLACE PROCEDURE `uklon_dwh.populate_dim_date_time`()
BEGIN
  DELETE FROM `uklon_dwh.dim_date_time` WHERE TRUE;
  
  INSERT INTO `uklon_dwh.dim_date_time`
  WITH date_range AS (
    SELECT DATE_ADD(DATE('2020-01-01'), INTERVAL seq DAY) AS full_date
    FROM UNNEST(GENERATE_ARRAY(0, 2555)) AS seq -- 7 years
  ),
  time_range AS (
    SELECT hour, minute
    FROM UNNEST(GENERATE_ARRAY(0, 23)) AS hour,
         UNNEST(GENERATE_ARRAY(0, 59)) AS minute
  )
  SELECT
    ROW_NUMBER() OVER (ORDER BY dr.full_date, tr.hour, tr.minute) AS date_time_key,
    dr.full_date,
    FORMAT_DATE('%Y-%m-%d', dr.full_date) AS date_string,
    EXTRACT(YEAR FROM dr.full_date) AS year,
    EXTRACT(QUARTER FROM dr.full_date) AS quarter,
    EXTRACT(MONTH FROM dr.full_date) AS month,
    FORMAT_DATE('%B', dr.full_date) AS month_name,
    EXTRACT(WEEK FROM dr.full_date) AS week_of_year,
    EXTRACT(DAY FROM dr.full_date) AS day_of_month,
    EXTRACT(DAYOFWEEK FROM dr.full_date) AS day_of_week,
    FORMAT_DATE('%A', dr.full_date) AS day_of_week_name,
    EXTRACT(DAYOFWEEK FROM dr.full_date) IN (1, 7) AS is_weekend,
    FALSE AS is_holiday,
    CAST(NULL AS STRING) AS holiday_name,
    tr.hour,
    tr.minute,
    CASE
      WHEN tr.hour BETWEEN 6 AND 11 THEN 'Morning'
      WHEN tr.hour BETWEEN 12 AND 17 THEN 'Afternoon'
      WHEN tr.hour BETWEEN 18 AND 21 THEN 'Evening'
      ELSE 'Night'
    END AS time_of_day,
    tr.hour BETWEEN 9 AND 18 AS is_business_hours,
    (tr.hour BETWEEN 7 AND 9) OR (tr.hour BETWEEN 17 AND 20) AS is_peak_hours,
    EXTRACT(YEAR FROM dr.full_date) AS fiscal_year,
    EXTRACT(QUARTER FROM dr.full_date) AS fiscal_quarter,
    EXTRACT(MONTH FROM dr.full_date) AS fiscal_month
  FROM date_range dr
  CROSS JOIN time_range tr;
END;