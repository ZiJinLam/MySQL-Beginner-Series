-- Check how many rows are there, making sure all the data imported properly
SELECT COUNT(*) 
FROM world_black_friday_sales.black_friday_sales;

-- Take a brief look on the data
SELECT * 
FROM black_friday_sales
LIMIT 10;
-- Unique keys: User_ID, Product_ID; Age is ranged; Occupation, Product_Categories are numberic

-- NULL checking
SELECT 
    SUM(CASE WHEN User_ID IS NULL THEN 1 ELSE 0 END) AS missing_col1,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS missing_col2,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS missing_col3,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS missing_col4,
    SUM(CASE WHEN Occupation IS NULL THEN 1 ELSE 0 END) AS missing_col5,
    SUM(CASE WHEN City_Category IS NULL THEN 1 ELSE 0 END) AS missing_col6,
    SUM(CASE WHEN Marital_Status IS NULL THEN 1 ELSE 0 END) AS missing_col7,
    SUM(CASE WHEN Product_Category_1 IS NULL THEN 1 ELSE 0 END) AS missing_col8,
    SUM(CASE WHEN Product_Category_2 IS NULL THEN 1 ELSE 0 END) AS missing_col9,
    SUM(CASE WHEN Product_Category_3 IS NULL THEN 1 ELSE 0 END) AS missing_col10,
    SUM(CASE WHEN Purchase IS NULL THEN 1 ELSE 0 END) AS missing_col12
FROM black_friday_sales; 
-- As there are no NaN, need not performing Data Cleaning and filling the NaN

-- Global Statistics
-- Average price per Product
SELECT AVG(Purchase)
FROM black_friday_sales;
-- Mean=9264

-- Pruchase per User
WITH t1 AS
(
SELECT DISTINCT User_ID, SUM(Purchase) OVER (PARTITION BY User_ID) AS total_purhcase
FROM black_friday_sales
)
SELECT AVG(total_purhcase)
FROM t1;
-- 865016


-- Check which Product_ID is the most popular
SELECT Product_ID, COUNT(*) AS sales_count, AVG(Purchase) AS average_sales
FROM black_friday_sales
GROUP BY Product_ID
ORDER BY sales_count DESC;
-- Most popular ProductID=P00265242; Highest average_sales' ProductID=P00086242, with 21256

SELECT Product_ID, Purchase, Product_Category_1, Product_Category_2, Product_Category_3
FROM black_friday_sales
WHERE Product_ID = 'P00265242';
-- Purchase Price vaires on the same product.
-- Global Statistics

-- Average of item purchased per user
WITH purchase_count AS 
(-- See how many trades does a User make
SELECT 
	User_ID, 
	COUNT(*) AS count_of_items
FROM black_friday_sales
GROUP BY User_ID
)
SELECT AVG(count_of_items)
FROM purchase_count;


SELECT *, SUM(Purchase) OVER(PARTITION BY User_ID) AS Total_purchase
FROM black_friday_sales;

DROP TABLE IF EXISTS distanct_bfs;

CREATE TABLE distanct_bfs AS
SELECT DISTINCT User_ID, Gender, Age, Occupation, City_Category, Stay_In_Current_City_Years, Marital_Status, SUM(Purchase) OVER(PARTITION BY User_ID) AS Total_purchase
FROM black_friday_sales;

SELECT User_ID, COUNT(*)
FROM black_friday_sales
WHERE User_ID = 1000001;

-- See relationship // gender and counts, expense
WITH t1 AS
(
-- Create a table which contains distinct user
SELECT DISTINCT User_ID, Gender, SUM(Purchase) OVER(PARTITION BY User_ID) AS Total_purchase
FROM black_friday_sales
)
SELECT Gender, COUNT(*), AVG(Total_purchase)
FROM t1
GROUP BY Gender;
-- Male buy a lot, with higher average expense

-- See relationship // age and counts, expense
WITH t1 AS
(
-- Create a table which contains distinct user
SELECT DISTINCT User_ID, Age, SUM(Purchase) OVER(PARTITION BY User_ID) AS Total_purchase
FROM black_friday_sales
)
SELECT Age, COUNT(*), AVG(Total_purchase)
FROM t1
GROUP BY Age;
-- 26-35 buy the most, almost double of the second place, interesting that the average expense for age group follows the counts of age group

-- See relationship // city and counts, expense
WITH t1 AS
(
-- Create a table which contains distinct user
SELECT DISTINCT User_ID, City_Category, Stay_In_Current_City_Years, SUM(Purchase) OVER(PARTITION BY User_ID) AS Total_purchase
FROM black_friday_sales
)
SELECT City_Category, Stay_In_Current_City_Years, COUNT(*), AVG(Total_purchase)
FROM t1
GROUP BY City_Category, Stay_In_Current_City_Years
ORDER BY City_Category, Stay_In_Current_City_Years DESC;
-- Intersting discovery: People who stay in 1 year has the largest group of people? 

-- Create a table to check the staying period of individuals in each city
WITH table_1 AS
(
-- Create a table which contains distinct user
SELECT DISTINCT User_ID, City_Category, Stay_In_Current_City_Years
FROM black_friday_sales
)
SELECT 
	City_Category, 
    Stay_In_Current_City_Years, 
    COUNT(*), 
    SUM(COUNT(*)) OVER (PARTITION BY City_Category ORDER BY Stay_In_Current_City_Years) AS rolling_total
FROM table_1
GROUP BY City_Category, Stay_In_Current_City_Years
ORDER BY City_Category, Stay_In_Current_City_Years DESC;
-- Reason for purchasing the most may be the larger group comparing to the restart
-- Interting discovery: The count of total follows the pattern of average expense in city, i.e. C > B > A --> The more people live in the city, in higher aveage expense?

-- See relationship // martial status and counts, expense
WITH t1 AS
(
-- Create a table which contains distinct user
SELECT DISTINCT User_ID, Marital_Status, SUM(Purchase) OVER(PARTITION BY User_ID) AS Total_purchase
FROM black_friday_sales
)
SELECT Marital_Status, COUNT(*), AVG(Total_purchase)
FROM t1
GROUP BY Marital_Status;
-- Those who are not married obviously buy more, while the average expense is similar

