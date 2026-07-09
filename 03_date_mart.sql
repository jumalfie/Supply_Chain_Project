
CREATE SCHEMA date_schema;

CREATE TABLE date_schema. updated_dates AS
SELECT 
    order_id, 
    customer_id, 
    CASE 
        WHEN order_placement_date LIKE '%/%' 
            THEN STRPTIME(order_placement_date, '%m/%d/%Y')
        WHEN order_placement_date LIKE '%-%' 
            THEN STRPTIME(order_placement_date, '%d-%m-%Y')
    END AS order_placement_date, 
    on_time, 
    in_full, 
    otif 
FROM fact_order_line;

SELECT * 
FROM 