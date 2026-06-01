CREATE OR ALTER VIEW dbo.V_product_performance AS
WITH cte_product_performance AS (
    SELECT
        date_month_name,
        date_month,
        product_code,
        product_name,
        category,
        sub_category,
        shade,
        finish_type,
        skin_type_target,
        size_ml,
        launch_year,
        product_status,
        production_cost,
        selling_price,
        brand,
        local_or_import,
        halal_certified,
        vegan_product,
        bpom_registered,
        supplier_name,
        warehouse_location,
        stock_qty,
        reorder_point,
        rating_average,
        review_count,

        SUM(CASE WHEN delivered_flag = 1 
            THEN net_sales 
            ELSE 0 
        END) AS total_sales,

        SUM(CASE 
            WHEN delivered_flag = 1 
            THEN quantity_sold 
            ELSE 0 
        END) AS total_quantity_sold,

        COUNT(transaction_id) AS total_transaction,

        COUNT(CASE 
            WHEN delivered_flag = 1 
            THEN transaction_id 
        END) AS Total_Delivered_Transaction,

        COUNT(CASE 
            WHEN Cancelled_flag = 1 
            THEN transaction_id 
        END) AS Total_Cancelled_transaction,

        COUNT(CASE 
            WHEN returned_flag = 1 
            THEN transaction_id 
        END) AS Total_returned_transaction,

        SUM(realized_profit_after_fee) AS total_realized_profit_after_fee,
        CASE
         WHEN stock_qty <= reorder_point THEN 'Need Restock'
            ELSE 'Stock Safe'
        END AS stock_status

    FROM dbo.V_base
    GROUP BY
        date_month_name,
        date_month,

        product_code,
        product_name,
        category,
        sub_category,
        shade,
        finish_type,
        skin_type_target,
        size_ml,
        launch_year,
        product_status,
        production_cost,
        selling_price,
        brand,
        local_or_import,
        halal_certified,
        vegan_product,
        bpom_registered,
        supplier_name,
        warehouse_location,
        stock_qty,
        reorder_point,
        rating_average,
        review_count
)

SELECT
    date_month_name,
    date_month,

    product_code,
    product_name,
    category,
    sub_category,
    shade,
    finish_type,
    skin_type_target,
    size_ml,
    launch_year,
    product_status,
    production_cost,
    selling_price,
    brand,
    local_or_import,
    halal_certified,
    vegan_product,
    bpom_registered,
    supplier_name,
    warehouse_location,
    stock_qty,
    reorder_point,
    rating_average,
    review_count,

    total_sales,
    total_quantity_sold,
    total_transaction,
    Total_Delivered_Transaction,
    Total_Cancelled_transaction,
    Total_returned_transaction,
    total_realized_profit_after_fee,
    stock_status,

    DENSE_RANK() OVER (
        PARTITION BY date_month
        ORDER BY total_quantity_sold DESC
    ) AS best_selling_rank,

    DENSE_RANK() OVER (
        PARTITION BY date_month
        ORDER BY total_sales ASC
    ) AS low_performing_rank,

    DENSE_RANK() OVER (
        PARTITION BY date_month, category
        ORDER BY total_quantity_sold DESC
    ) AS rank_in_category

FROM cte_product_performance;
GO