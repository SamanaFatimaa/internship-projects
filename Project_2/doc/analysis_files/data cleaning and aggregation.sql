-- Create a new database named 'sales'
CREATE DATABASE sales;

-- Select the 'sales' database for all upcoming operations
USE sales;

-- ============================
-- Basic Data Exploration
-- ============================

-- View the entire contents of the table 'raw_sales_data'
SELECT * FROM raw_sales_data;

-- View only the first 5 rows of the table (helps in quick preview)
SELECT * FROM raw_sales_data
LIMIT 5;

-- Count the total number of rows in the table
SELECT COUNT(*) FROM raw_sales_data;

-- Display structure of the table (columns, data types, nullability, etc.)
DESCRIBE raw_sales_data;

-- ============================
-- Duplicate Entry Checks
-- ============================

-- Find duplicate rows based on customer name, email, product, and date
-- Useful for identifying exact or near-duplicate transactions
SELECT raw_sales_data.Customer_Name AS duplicate_names, Email, Product_Category, Order_Date,
COUNT(*) AS count
FROM raw_sales_data
GROUP BY Customer_Name, Email, Product_Category, Order_Date
HAVING count > 1;

-- Find customers who appear more than once (may be repeat buyers or duplicates)
SELECT raw_sales_data.Customer_Name AS duplicate_names,
COUNT(*) AS count
FROM raw_sales_data
GROUP BY Customer_Name
HAVING count > 1;

-- Count total orders by a specific repeat customer ('Alice Smith')
SELECT Customer_Name AS repeat_customer, 
COUNT(*) AS total_orders
FROM raw_sales_data
WHERE Customer_Name = 'Alice Smith'
GROUP BY Customer_Name;

-- Show each order by 'Alice Smith' with details (helps in analyzing purchase pattern)
SELECT Customer_Name AS repeat_customer, Order_ID, Email, Product_Category, Order_Date
FROM raw_sales_data
WHERE Customer_Name = 'Alice Smith'
GROUP BY Customer_Name, Order_ID, Email, Product_Category, Order_Date;

-- ============================
-- Data Cleaning
-- ============================

-- Preview case sensitivity: see if 'john doe' exists in lowercase (likely won’t match 'John Doe')
SELECT customer_name 
FROM raw_sales_data
WHERE customer_name = 'john doe';

-- Delete duplicate rows for 'John Doe' but keep the first (based on MIN(Order_ID))
-- This removes exact duplicates while retaining one unique record
DELETE FROM raw_sales_data
WHERE Customer_Name = 'John Doe'
  AND Order_ID NOT IN (
    SELECT * FROM (
      SELECT MIN(Order_ID)
      FROM raw_sales_data
      WHERE Customer_Name = 'John Doe'
      GROUP BY Customer_Name, Email, Phone, Product_Category, Order_Date, Revenue, `Discount (%)`
    ) AS keep_one
  );

-- Replace missing or blank email values with a placeholder
UPDATE raw_sales_data
SET Email = 'not_provided@gmail.com'
WHERE Email IS NULL OR Email = '';

-- Replace missing or blank phone numbers with 'Unknown'
UPDATE raw_sales_data
SET Phone = 'Unknown'
WHERE Phone IS NULL OR Phone = '';

-- Replace missing or zero discount values with 'Unknown' (assumes 0 means not recorded)
UPDATE raw_sales_data
SET `Discount (%)` = 'Unknown'
WHERE `Discount (%)` IS NULL OR `Discount (%)` = '0';

-- Convert Order_Date strings into proper DATE format, handling both '/' and '-' formats
-- Ensures all dates are stored consistently for analysis
UPDATE raw_sales_data
SET Order_Date = CASE
    WHEN Order_Date LIKE '%/%' THEN STR_TO_DATE(Order_Date, '%m/%d/%Y')
    WHEN LENGTH(Order_Date) = 8 AND Order_Date LIKE '%-%' THEN STR_TO_DATE(Order_Date, '%m-%d-%y')
    WHEN LENGTH(Order_Date) = 10 AND Order_Date LIKE '%-%' THEN STR_TO_DATE(Order_Date, '%m-%d-%Y')
    ELSE NULL
END;

-- View the full cleaned and updated table after all transformations
SELECT * FROM raw_sales_data;


-- Data exploration
-- 1. Calculate total revenue per product category to determine the most profitable segments.
select Product_Category, sum(Revenue) as Total_Revenue
from raw_sales_data
group by Product_Category;

-- 2. Find the average discount applied across different customer segments to analyse discount effectiveness.
select product_category, AVG(`Discount (%)`) as avg_discount
from raw_sales_data
group by product_category;

-- 3. Analyse monthly sales trends to identify peak sales periods.

select month(order_date) as month, sum(revenue) as total_sales
from raw_sales_data
group by month(order_date)
order by month asc;

-- Create and Save cleaned sales data as a new file

create table sales_data_cleaned AS
select * from raw_sales_data;

select * from sales_data_cleaned; 

