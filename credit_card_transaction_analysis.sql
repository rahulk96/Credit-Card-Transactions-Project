--Credit Card Transaction Analysis

--SQL Server | Advanced SQL | Window Functions | Business Insights

--Database Setup
CREATE DATABASE credit_card_db;
GO

USE credit_card_db;
GO

DROP TABLE IF EXISTS credit_card_transactions;

CREATE TABLE credit_card_transactions (
    transaction_id   INT,
    city             VARCHAR(100),
    transaction_date DATE,
    card_type        VARCHAR(50),
    exp_type         VARCHAR(50),
    gender           VARCHAR(10),
    amount           DECIMAL(18,2)
);

BULK INSERT credit_card_transactions
FROM 'credit_card_transactions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


--Data Validation Checks
--1 Total Record Count
SELECT COUNT(*) AS Total_Rows
FROM credit_card_transactions;


--2 NULL Value Check
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS transaction_id_nulls,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS transaction_date_nulls,
    SUM(CASE WHEN card_type IS NULL THEN 1 ELSE 0 END) AS card_type_nulls,
    SUM(CASE WHEN exp_type IS NULL THEN 1 ELSE 0 END) AS exp_type_nulls,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_nulls,
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS amount_nulls
FROM credit_card_transactions;


--3 Duplicate Transaction Check
SELECT transaction_id, COUNT(*) AS Duplicate_Count
FROM credit_card_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


--Business Analysis Queries
--1. Top 5 Cities by Total Spend & Contribution %
WITH total_spent_cte AS (
    SELECT SUM(CAST(amount AS BIGINT)) AS total_spent
    FROM credit_card_transactions
)
SELECT TOP 5
    city,
    SUM(amount) AS total_spend,
    total_spent,
    CAST((SUM(amount) * 1.0 / total_spent) * 100 AS DECIMAL(5,2)) AS percentage_contribution
FROM credit_card_transactions, total_spent_cte
GROUP BY city, total_spent
ORDER BY total_spend DESC;


--2. Highest Spend Month per Card Type
WITH monthly_spend AS (
    SELECT
        card_type,
        DATEPART(YEAR, transaction_date) AS Year,
        DATENAME(MONTH, transaction_date) AS Month,
        SUM(amount) AS Monthly_Expense
    FROM credit_card_transactions
    GROUP BY card_type,
             DATEPART(YEAR, transaction_date),
             DATENAME(MONTH, transaction_date)
),
ranked_data AS (
    SELECT *,
           RANK() OVER (PARTITION BY card_type ORDER BY Monthly_Expense DESC) AS rn
    FROM monthly_spend
)
SELECT card_type, Year, Month, Monthly_Expense
FROM ranked_data
WHERE rn = 1;


--3. Cumulative ₹1,000,000 Spend Milestone per Card Type
WITH cumulative_spend AS (
    SELECT *,
           SUM(amount) OVER (
               PARTITION BY card_type
               ORDER BY transaction_date, transaction_id
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS cum_sum
    FROM credit_card_transactions
),
threshold_reached AS (
    SELECT *,
           RANK() OVER (PARTITION BY card_type ORDER BY cum_sum ASC) AS rn
    FROM cumulative_spend
    WHERE cum_sum >= 1000000
)
SELECT *
FROM threshold_reached
WHERE rn = 1
ORDER BY card_type;


--4. Year-Wise Running Total Spend
WITH yearly_spend AS (
    SELECT
        DATEPART(YEAR, transaction_date) AS Year,
        SUM(amount) AS Total_Year_Spend
    FROM credit_card_transactions
    GROUP BY DATEPART(YEAR, transaction_date)
)
SELECT
    Year,
    Total_Year_Spend,
    SUM(Total_Year_Spend) OVER (
        ORDER BY Year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Total_Spend
FROM yearly_spend
ORDER BY Year;


--5. City with Lowest Gold Card Spend Contribution
SELECT
    city,
    SUM(amount) AS total_spend,
    SUM(CASE WHEN card_type = 'Gold' THEN amount ELSE 0 END) AS gold_spend,
    ROUND(
        (SUM(CASE WHEN card_type = 'Gold' THEN amount ELSE 0 END) * 1.0 / SUM(amount)) * 100,
        2
    ) AS gold_contribution
FROM credit_card_transactions
GROUP BY city
HAVING SUM(CASE WHEN card_type = 'Gold' THEN amount ELSE 0 END) > 0
ORDER BY gold_contribution;


--6. Highest & Lowest Expense Type per City
WITH city_expense AS (
    SELECT city, exp_type, SUM(amount) AS total_spend
    FROM credit_card_transactions
    GROUP BY city, exp_type
),
ranked_expense AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY total_spend DESC) AS rn_high,
           RANK() OVER (PARTITION BY city ORDER BY total_spend ASC) AS rn_low
    FROM city_expense
)
SELECT
    city,
    MAX(CASE WHEN rn_high = 1 THEN exp_type END) AS Highest_Expense_Type,
    MAX(CASE WHEN rn_low = 1 THEN exp_type END) AS Lowest_Expense_Type
FROM ranked_expense
WHERE rn_high = 1 OR rn_low = 1
GROUP BY city;


--7. Gender Contribution % by Expense Type
SELECT
    exp_type,
    SUM(amount) AS total_spend,
    SUM(CASE WHEN gender = 'M' THEN amount ELSE 0 END) AS male_spend,
    SUM(CASE WHEN gender = 'F' THEN amount ELSE 0 END) AS female_spend,
    ROUND(SUM(CASE WHEN gender = 'M' THEN amount ELSE 0 END) * 1.0 / SUM(amount) * 100, 2) AS male_contribution,
    ROUND(SUM(CASE WHEN gender = 'F' THEN amount ELSE 0 END) * 1.0 / SUM(amount) * 100, 2) AS female_contribution
FROM credit_card_transactions
GROUP BY exp_type;


--8. Highest MoM Growth (Card + Expense Type) in Jan 2014
WITH monthly_data AS (
    SELECT
        card_type,
        exp_type,
        DATEPART(YEAR, transaction_date) AS Year,
        DATEPART(MONTH, transaction_date) AS Month,
        SUM(amount) AS total_spend
    FROM credit_card_transactions
    GROUP BY card_type, exp_type,
             DATEPART(YEAR, transaction_date),
             DATEPART(MONTH, transaction_date)
),
growth_data AS (
    SELECT *,
           LAG(total_spend) OVER (
               PARTITION BY card_type, exp_type
               ORDER BY Year, Month
           ) AS prev_month_spend
    FROM monthly_data
)
SELECT TOP 1 *,
       (total_spend - prev_month_spend) AS MoM_Growth
FROM growth_data
WHERE prev_month_spend IS NOT NULL
  AND Year = 2014
  AND Month = 1
ORDER BY MoM_Growth DESC;


--9. Weekend Spend Ratio by City
SELECT
    city,
    SUM(amount) * 1.0 / COUNT(*) AS Spend_To_Transaction_Ratio
FROM credit_card_transactions
WHERE DATEPART(WEEKDAY, transaction_date) IN (1, 7)
GROUP BY city
ORDER BY Spend_To_Transaction_Ratio DESC;