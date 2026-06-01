CREATE OR ALTER VIEW V_customer_insight AS
WITH cte_customer AS (
    SELECT
        customer_key,
        customer_id ,
        customer_name ,
        customer_gender ,
        customer_age ,
        city ,
        province ,
        membership_tier,
        delivered_flag,
        Cancelled_flag,
        returned_flag,
        COUNT(transaction_id) AS total_transaction,
        COUNT(CASE WHEN delivered_flag=1 THEN 1 END) Total_Delivered_Transaction,
        COUNT(CASE WHEN cancelled_flag=1 THEN 1 END) Total_Cancelled_transaction,
        COUNT(CASE WHEN returned_flag=1 THEN 1 END) Total_returned_transaction,

        SUM(gross_sales) AS total_spending,

        SUM(quantity_sold) AS total_quantity_bought,

        SUM(realized_profit_after_fee) AS total_realized_profit_after_fee,
        SUM(customer_rating) AS customer_rating_count,
        category,
        brand,
        skin_type_target,
        product_status,
        delivery_status,
        date_month,
        date_month_name,
        platform


    FROM dbo.V_base
    GROUP BY 
        customer_key,
        customer_id ,
        customer_name ,
        customer_gender ,
        customer_age ,
        city ,
        province ,
        membership_tier,
        delivered_flag,
        Cancelled_flag,
        returned_flag,
        category,
        brand,
        skin_type_target,
        product_status,
        delivery_status,
        date_month,
        date_month_name,
        platform
)

SELECT
    customer_key,
    customer_id,
    customer_name,
    customer_gender,
    customer_age,

    CASE
        WHEN customer_age < 18 THEN '<18'
        WHEN customer_age BETWEEN 18 AND 24 THEN '18-24'
        WHEN customer_age BETWEEN 25 AND 34 THEN '25-34'
        WHEN customer_age BETWEEN 35 AND 44 THEN '35-44'
        WHEN customer_age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,

    city,
    province,
    membership_tier,

    total_transaction,
    total_delivered_transaction,
    total_cancelled_transaction,
    total_returned_transaction,

    total_spending,
    total_quantity_bought,
    total_realized_profit_after_fee,
    delivered_flag,
        cancelled_flag,
        returned_flag,
        customer_rating_count,
        category,
        brand,
        skin_type_target,
        product_status,
        delivery_status,
        date_month,
        date_month_name,
        platform

FROM cte_customer;
GO