CREATE DATABASE walmart_sales;
USE walmart_sales;

CREATE TABLE sales_data (
    invoice_id VARCHAR(20),
    branch VARCHAR(5),
    city VARCHAR(50),
    customer_type VARCHAR(10),
    gender VARCHAR(10),
    product_line VARCHAR(50),
    unit_price DECIMAL(10, 2),
    quantity INT,
    tax DECIMAL(10, 5),
    total DECIMAL(10, 5),
    sale_date DATE,
    sale_time TIME,
    payment VARCHAR(20),
    cogs DECIMAL(10, 2),
    gross_margin_percentage DECIMAL(10, 9),
    gross_income DECIMAL(10, 5),
    rating DECIMAL(3, 1),
    customer_id INT
);



--  Task 1: Identifying the Top Branch by Sales Growth Rate (6 Marks)
--  Walmart wants to identify which branch has exhibited the highest sales growth over time. Analyze the total sales
--  for each branch and compare the growth rate across months to find the top performer.
-- arranging total sales by month
SELECT branch, MONTH(sale_date) AS sale_month, YEAR(sale_date) AS sale_year, 
SUM(total) AS monthly_total_sales
FROM sales_data
GROUP BY branch, sale_year, sale_month
ORDER BY branch, sale_year, sale_month;

-- growth rate monthly using CTE
WITH sales_growth AS (
    SELECT branch, sale_year, sale_month, monthly_total_sales,
           LAG(monthly_total_sales) 
           OVER (PARTITION BY branch ORDER BY sale_year, sale_month) AS prev_month_sales
    FROM (
        SELECT branch, YEAR(sale_date) AS sale_year, MONTH(sale_date) AS sale_month, 
        SUM(total) AS monthly_total_sales
        FROM sales_data
        GROUP BY branch, sale_year, sale_month
    ) AS monthly_data
)
-- SELECT * FROM sales_growth;

-- calculation of avg growth rate
SELECT branch, 
AVG((monthly_total_sales - prev_month_sales) / NULLIF(prev_month_sales, 0)) * 100 AS avg_growth_rate
FROM sales_growth
WHERE prev_month_sales IS NOT NULL
GROUP BY branch
ORDER BY avg_growth_rate DESC
LIMIT 1;





--  Task 2: Finding the Most Profitable Product Line for Each Branch (6 Marks)
--  Walmart needs to determine which product line contributes the highest profit to each branch.The profit margin
--  should be calculated based on the difference between the gross income and cost of goods sold.
SELECT branch, product_line, total_profit
FROM (SELECT branch, product_line, SUM(gross_income - cogs) AS total_profit,
RANK() OVER (PARTITION BY branch ORDER BY SUM(gross_income - cogs) DESC) AS ranking
FROM sales_data
GROUP BY branch, product_line
) AS ranked_products
WHERE ranking = 1
ORDER BY branch;








--  Task 3: Analyzing Customer Segmentation Based on Spending (6 Marks)
--  Walmart wants to segment customers based on their average spending behavior. Classify customers into three
--  tiers: High, Medium, and Low spenders based on their total purchase amounts.
SELECT customer_id, AVG(total) AS avg_spending,
CASE
WHEN AVG(total) > 350 THEN 'High'
WHEN AVG(total) >= 300 THEN 'Medium'
ELSE 'Low'
END AS spending_category
FROM sales_data
GROUP BY customer_id
ORDER BY avg_spending DESC;






--  Task 4: Detecting Anomalies in Sales Transactions (6 Marks)
-- Walmart suspects that some transactions have unusually high or low sales compared to the average for the
--  product line. Identify these anomalies.
SELECT invoice_id, product_line, total,
CASE
WHEN total > 1040 THEN 'High Anomaly'
WHEN total < 12 THEN 'Low Anomaly'
ELSE 'Normal'
END AS anomaly_type
FROM sales_data
WHERE total > 1040 OR total < 12
ORDER BY product_line, total DESC;





--  Task 5: Most Popular Payment Method by City (6 Marks)
--  Walmart needs to determine the most popular payment method in each city to tailor marketing strategies.
SELECT city, payment, transaction_count
FROM (
SELECT city, payment, COUNT(*) AS transaction_count,
RANK() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS ranking
FROM sales_data
GROUP BY city, payment
) AS ranked_payments
WHERE ranking = 1
ORDER BY city;






--  Task 6: Monthly Sales Distribution by Gender (6 Marks)
--  Walmart wants to understand the sales distribution between male and female customers on a monthly basis.
SELECT MONTH(sale_date) AS sale_month, gender, SUM(total) AS total_sales
FROM sales_data
GROUP BY MONTH(sale_date), gender
ORDER BY sale_month, gender;





--  Task 7: Best Product Line by Customer Type (6 Marks)
--  Walmart wants to know which product lines are preferred by different customer types(Member vs. Normal).
SELECT customer_type, product_line, total_sales
FROM (
SELECT customer_type, product_line, SUM(total) AS total_sales,
RANK() OVER (PARTITION BY customer_type ORDER BY SUM(total) DESC) AS ranking
FROM sales_data
GROUP BY customer_type, product_line
) AS ranked_product_lines
WHERE ranking = 1
ORDER BY customer_type;





--  Task 8: Identifying Repeat Customers (6 Marks)
--  Walmart needs to identify customers who made repeat purchases within a specific time frame (e.g., within 30
--  days).
SELECT customer_id, COUNT(*) AS repeat_count
FROM (
SELECT customer_id, sale_date, 
LEAD(sale_date) OVER (PARTITION BY customer_id ORDER BY sale_date) AS next_sale_date,
DATEDIFF(LEAD(sale_date) OVER (PARTITION BY customer_id ORDER BY sale_date), sale_date) AS days_between
FROM sales_data
) AS customer_purchases
WHERE days_between <= 30
GROUP BY customer_id
ORDER BY repeat_count DESC;





--  Task 9: Finding Top 5 Customers by Sales Volume (6 Marks)
--  Walmart wants to reward its top 5 customers who have generated the most sales Revenue.
SELECT customer_id, SUM(total) AS total_sales
FROM sales_data
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;





--  Task 10: Analyzing Sales Trends by Day of the Week (6 Marks)
--  Walmart wants to analyze the sales patterns to determine which day of the week
--  brings the highest sales.
SELECT DAYNAME(sale_date) AS day_of_week, SUM(total) AS total_sales
FROM sales_data
GROUP BY DAYNAME(sale_date)
ORDER BY total_sales DESC;





