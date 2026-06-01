--CREATE OR ALTER VIEW V_sales_performance AS
SELECT
    transaction_date,
    date_year,
    date_quarter,
    date_month,
    date_month_name,
    platform,
    order_source,
    sales_channel_type,
    campaign_name,
    SUM(net_sales) AS total_sales,
    COUNT(customer_key) AS total_customer,
    COUNT(transaction_id) AS total_transaction,
    COUNT(CASE WHEN delivered_flag=1 THEN 1 END) Total_Delivered_Transaction,
    COUNT(CASE WHEN cancelled_flag=1 THEN 1 END) Total_Cancelled_transaction,
    COUNT(CASE WHEN returned_flag=1 THEN 1 END) Total_returned_transaction,
    SUM(quantity_sold) AS total_quantity_sold,
    SUM(realized_profit_after_fee) AS total_realized_profit_after_fee,
    SUM(customer_rating) AS customer_rating_count,
    SUM(platform_fee) AS total_platform_fee,
    SUM(discount_amount) AS total_discount_amount,
    SUM(gross_sales) AS total_gross_sales

FROM dbo.V_base
GROUP BY
    transaction_date,
    date_year,
    date_quarter,
    date_month,
    date_month_name,
    platform,
    order_source,
    campaign_name,
    sales_channel_type;
GO