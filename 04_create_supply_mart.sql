--Step 4: Creating a date mart 

DROP SCHEMA IF EXISTS supply_mart CASCADE;

CREATE SCHEMA supply_mart;

SELECT '=== loading products dim for supply_mart ===' AS info;

CREATE OR REPLACE TABLE supply_mart.products_dim (
    product_id      INTEGER     PRIMARY KEY,
    product_name    VARCHAR,
    category        VARCHAR
); 

INSERT INTO supply_mart.products_dim (product_id, product_name, category)
SELECT 
    product_id, 
    product_name, 
    category 
FROM dim_products;


SELECT '=== Loading Product Monthly Supply Sample==' AS info;
CREATE OR REPLACE TABLE supply_mart.product_monthly_supply (
    month_delivery_date    DATE,
    year                INTEGER,
    month               INTEGER,
    quarter             INTEGER,
    quarter_name        VARCHAR,
    year_quarter        VARCHAR,
    product_id          INTEGER,
    FOREIGN KEY (product_id) REFERENCES supply_mart.products_dim(product_id)
); 

INSERT INTO supply_mart.product_monthly_supply( 
    month_delivery_date,    
    year,                
    month,               
    quarter,             
    quarter_name,        
    year_quarter, 
    product_id
) 
SELECT 
    DATE_TRUNC ('month', actual_delivery_date) AS month_delivery_date, 
    EXTRACT(YEAR FROM actual_delivery_date) AS year,
    EXTRACT(MONTH FROM actual_delivery_date) AS month,
    EXTRACT(QUARTER FROM actual_delivery_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM actual_delivery_date) :: VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM actual_delivery_date):: VARCHAR || '-Q' ||
    EXTRACT(QUARTER FROM actual_delivery_date) :: VARCHAR AS year_quarter,
    product_id
FROM fact_order_line 
ORDER BY month_delivery_date;

SELECT '=== Loading date_mart Fact_Product_Monthly_Supply ===' AS info;

CREATE OR REPLACE TABLE supply_mart.fact_product_monthly_supply AS 
SELECT 
    pd.product_name, 
    pd.category,
    pmd.month_delivery_date,    
    pmd.year,                
    pmd.month,               
    pmd.quarter,             
    pmd.quarter_name,        
    pmd.year_quarter 
FROM supply_mart.products_dim AS pd 
LEFT JOIN supply_mart.product_monthly_supply AS pmd 
    ON pd.product_id = pmd.product_id;

SELECT '=== Product dim Sample==' AS info;
SELECT * 
FROM supply_mart.products_dim 
LIMIT 10;


SELECT '=== Product Monthly Supply Sample==' AS info;
SELECT * 
FROM supply_mart.product_monthly_supply
LIMIT 10; 

SELECT '=== Fact_Product_Monthly_Supply Sample ===' AS info;
SELECT *
FROM supply_mart.fact_product_monthly_supply;