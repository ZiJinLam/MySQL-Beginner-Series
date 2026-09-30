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
-- Average on sales
SELECT AVG(Purchase)
FROM black_friday_sales;
-- Mean=9264

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

-- See relationship // gender and counts, expense
SELECT Gender, COUNT(*), AVG(Purchase)
FROM black_friday_sales
GROUP BY Gender;
-- Male buy a lot, while the aveage expense is slightly higher, comparing to Female

-- See relationship // age and counts, expense
SELECT Age, COUNT(*), AVG(Purchase)
FROM black_friday_sales
GROUP BY Age;
-- 26-35 buy the most, double of the second place, highlight would be the average expense of this age group < total aveage (9264)

-- See relationship // city and counts, expense
SELECT City_Category, Stay_In_Current_City_Years, COUNT(*), AVG(Purchase)
FROM black_friday_sales
GROUP BY City_Category, Stay_In_Current_City_Years
ORDER BY City_Category, Stay_In_Current_City_Years DESC;
-- Intersting discovery: People who stay in 1 year purchases the most; Larger group of people? Or having a higher need? Or else?
-- Interesting Pattern: The average purchase of each City has an order, i.e. C > B > A

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
SELECT Marital_Status, COUNT(*), AVG(Purchase)
FROM black_friday_sales
GROUP BY Marital_Status;
-- Those who are not married obviously buy more, while the average expense is similar

