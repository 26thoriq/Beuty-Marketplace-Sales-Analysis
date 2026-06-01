-- Create the date dimension table
CREATE TABLE dim.[date] (
    transaction_date DATE PRIMARY KEY, 
    date_year INT,
    date_month INT,
    date_month_name VARCHAR(20),
    date_day INT,
    date_day_name VARCHAR(20),
    date_quarter INT
);
GO

-- Declare variables to store the date range
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

-- 1. Get the exact minimum and maximum dates from the fact table
SELECT 
    @StartDate = MIN(transaction_date), 
    @EndDate = MAX(transaction_date)
FROM fact.sales_transactions; 

-- 2. Generate dates day by day using a Recursive CTE
WITH DateGenerator AS (
    SELECT @StartDate AS transaction_date
    
    UNION ALL

    SELECT DATEADD(DAY, 1, transaction_date)
    FROM DateGenerator
    WHERE transaction_date < @EndDate
)

-- 3. Insert the generated data into your date dimension table
INSERT INTO dim.[date] (
    transaction_date, 
    date_year, 
    date_month, 
    date_month_name, 
    date_day, 
    date_day_name, 
    date_quarter
)
SELECT 
    transaction_date,
    YEAR(transaction_date),
    MONTH(transaction_date),
    DATENAME(MONTH, transaction_date),
    DAY(transaction_date),
    DATENAME(WEEKDAY, transaction_date),
    DATEPART(QUARTER, transaction_date)
FROM DateGenerator
OPTION (MAXRECURSION 0); -- Remove the recursion limit to allow generation of all dates
GO