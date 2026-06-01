

/* =========================================================
   STEP 1: Update province based on city reference table
   Purpose:
   - Replace incorrect province values in fact table
   - Use dim.reference_city as the trusted reference source
   ========================================================= */

UPDATE f
SET f.province = r.province
FROM fact.sales_transactions f
LEFT JOIN dim.reference_city r
ON f.city = r.city
WHERE f.province <> r.province;
GO


/* =========================================================
   STEP 2: Clean transaction value
   ========================================================= */

--Before updating table, alter delivery_days and customer_rating to NULLABLE
ALTER TABLE fact.sales_transactions
ALTER COLUMN delivery_days TINYINT NULL;
GO
ALTER TABLE fact.sales_transactions
ALTER COLUMN customer_rating TINYINT NULL;
GO


UPDATE fact.sales_transactions
-- Standardize return_reason
SET 
    return_reason = CASE
        WHEN returned_flag = 1 
             AND (return_reason IS NULL OR LTRIM(RTRIM(return_reason)) = '')
            THEN 'Unknown'
        WHEN returned_flag = 0
            THEN 'Not Returned'
        ELSE return_reason
    END,

-- Clean sales_channel_type
    sales_channel_type = CASE
        WHEN platform = 'Offline Store'
            THEN 'Offline'
        ELSE 'Online'
    END,

-- Adjust net_sales based on delivery_status
    net_sales = CASE
        WHEN delivery_status = 'Delivered'
            THEN net_sales
        ELSE 0
    END,

-- Remove delivery_days for cancelled orders and platform=offline store
    delivery_days = CASE
        WHEN delivery_status = 'Cancelled'
            THEN NULL
        WHEN platform = 'Offline Store'
                          THEN NULL
        ELSE delivery_days
    END,
-- Remove customer_rating for cancelled,returned orders
    customer_rating = CASE
        WHEN delivery_status = 'Cancelled'
            THEN NULL
        WHEN delivery_status = 'Returned'
            THEN NULL
        ELSE customer_rating
    END,
-- Adjust gross_sales based on delivery_status
     gross_sales = CASE
                      WHEN delivery_status = 'Delivered'
                          THEN gross_sales
                     ELSE 0
    END,
-- Adjust platform_fee based on platform
     platform_fee = CASE
                      WHEN platform = 'Offline Store' OR platform='Website'
                          THEN 0
                     ELSE platform_fee
    END,
-- Adjust shipping_cost based on platform
    shipping_cost = CASE
                      WHEN platform = 'Offline Store'
                          THEN 0
                     ELSE shipping_cost
    END,
--Adjust order_source based on platform
    order_source = CASE
                      WHEN platform = 'Offline Store'
                          THEN 'Organic'
                     ELSE order_source
    END;
GO


/* =========================================================
   STEP 3: Make unique_customer_id using ROW_NUMBER()
   ========================================================= */
IF COL_LENGTH('fact.sales_transactions', 'unique_customer_id') IS NULL
BEGIN
    ALTER TABLE fact.sales_transactions
    ADD unique_customer_id VARCHAR(100);
END;
GO
WITH cte_customer_id AS (
    SELECT
        transaction_id,
        CONCAT(
            customer_id,
            '-',
            ROW_NUMBER() OVER (
                PARTITION BY customer_id
                ORDER BY transaction_date, transaction_id
            )
        ) AS new_customer_id
    FROM fact.sales_transactions
)

UPDATE f
SET 
    f.unique_customer_id = c.new_customer_id
FROM fact.sales_transactions AS f
INNER JOIN cte_customer_id AS c
    ON f.transaction_id = c.transaction_id;
GO


/* =========================================================
   STEP 4: create new column : Cancelled_Flag
   ========================================================= */
   IF COL_LENGTH('fact.sales_transactions', 'Cancelled_flag') IS NULL
BEGIN
ALTER TABLE fact.sales_transactions
    ADD Cancelled_flag BIT;
    END;
GO

UPDATE fact.sales_transactions
SET 
    Cancelled_flag= CASE
                        WHEN delivery_status='Cancelled'
                        THEN 1
                    ELSE 0
                    END;
/* =========================================================
   STEP 5: create new column : delivered_Flag
   ========================================================= */
   IF COL_LENGTH('fact.sales_transactions', 'delivered_flag') IS NULL
BEGIN
ALTER TABLE fact.sales_transactions
    ADD delivered_flag BIT;
    END;
GO

UPDATE fact.sales_transactions
SET 
    delivered_flag= CASE
                        WHEN delivery_status='Delivered'
                        THEN 1
                    ELSE 0
                    END;

/* =========================================================
   STEP 6: create new column : quantity_sold
   ========================================================= */
   IF COL_LENGTH('fact.sales_transactions', 'quantity_sold') IS NULL
BEGIN
ALTER TABLE fact.sales_transactions
    ADD quantity_sold TINYINT;
    END;
GO

UPDATE fact.sales_transactions
SET 
    quantity_sold= CASE
                        WHEN Cancelled_flag = 0 AND returned_flag = 0
                        THEN quantity
                        ELSE  0
                    END;
GO
