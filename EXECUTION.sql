CREATE SCHEMA IF NOT EXISTS `your-project.uklon_staging`
OPTIONS(
  description = "Staging area for ETL processes",
  location = "EU"
);

CREATE SCHEMA IF NOT EXISTS `your-project.uklon_dwh`
OPTIONS(
  description = "Production data warehouse - Star Schema",
  location = "EU"
);

   # Execute these in BigQuery Console or using bq command-line
   bq query < 1_dim_customers.sql
   bq query < 2_dim_drivers.sql
   bq query < 3_dim_products.sql
   bq query < 4_dim_promo_campaigns.sql
   bq query < 5_dim_date_time.sql
   bq query < 6_dim_location.sql
   
      bq query < 7_fact_orders.sql
   bq query < 8_fact_payments.sql
   bq query < 9_fact_promo_usage.sql
   
    bq query < 10_etl_source_to_staging.sql
   bq query < 11_etl_staging_to_dimensions.sql
   bq query < 12_etl_staging_to_facts.sql
   
   CALL `your-project.uklon_dwh.populate_dim_date_time`();

-- Run full ETL pipeline
CALL `your-project.uklon_dwh.run_full_etl`();

gcloud scheduler jobs create bigquery uklon-daily-etl \
  --schedule="0 2 * * *" \
  --location=europe-west1 \
  --time-zone="Europe/Kyiv" \
  --query="CALL \`your-project.uklon_dwh.run_full_etl\`()"
  
  SELECT * FROM `your-project.uklon_dwh.v_product_performance`;