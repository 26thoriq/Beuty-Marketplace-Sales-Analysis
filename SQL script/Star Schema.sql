
-- 1. Create 'fact' schema
CREATE SCHEMA fact;
GO

-- 2. Create 'dim' schema
CREATE SCHEMA dim;
GO

-- 3. Move sales_transactions table from 'dbo' to 'fact' schema
ALTER SCHEMA fact TRANSFER dbo.sales_transactions;
GO


-- 4. Move products table from 'dbo' to 'dim' schema
ALTER SCHEMA dim TRANSFER dbo.products;
GO

-- 5. Create relationship between Fact table and Product Dimension
ALTER TABLE fact.sales_transactions
ADD CONSTRAINT FK_FactSales_DimProducts
FOREIGN KEY (product_code) REFERENCES dim.products(product_code);
GO

-- 6. Create relationship between Fact table and Date Dimension
ALTER TABLE fact.sales_transactions
ADD CONSTRAINT FK_FactSales_DimDate
FOREIGN KEY (transaction_date) REFERENCES dim.[date](transaction_date);
GO