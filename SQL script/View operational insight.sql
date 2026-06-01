CREATE OR ALTER VIEW V_operational_insight AS
SELECT
    date_year,
    date_quarter,
    date_month,
    date_month_name,
    platform,
    order_source,
    sales_channel_type,
    warehouse_origin,
    delivery_status,
    
    returned_flag,
    return_reason,
    COUNT(transaction_id) AS total_transaction,
    COUNT(CASE WHEN delivered_flag=1 THEN 1 END) Total_Delivered_Transaction,
    COUNT(CASE WHEN cancelled_flag=1 THEN 1 END) Total_Cancelled_transaction,
    COUNT(CASE WHEN returned_flag=1 THEN 1 END) Total_returned_transaction,
    SUM(delivery_days) AS delivery_days_count,
    campaign_name,
    payment_method

FROM dbo.V_base
GROUP BY
    date_year,
    date_quarter,
    date_month,
    date_month_name,
    platform,
    order_source,
    sales_channel_type,
    warehouse_origin,
    delivery_status,
    returned_flag,
    return_reason,
    campaign_name,
    payment_method
