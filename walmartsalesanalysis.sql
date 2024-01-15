CREATE DATABASE IF NOT EXISTS salesDataWalmart;

USE salesDataWalmart;
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);
Select * from sales;
----- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -----
 ----- ----------------------------------------------------------------FEATURE ENGINEERING--------------------------------------------------------------------------------------- -----
  ----- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -----


-- ADD TIME COLUMN-- 
alter table sales
drop column time_of_day;
alter table sales ADD COLUMN Day_of_time varchar(20);
UPDATE sales
SET Day_of_time = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);


--  ADD DAYNAME COLUMN -- 
-- Step 1: Add a new column to the table
ALTER TABLE sales
ADD COLUMN day_name VARCHAR(10);

-- Step 2: Update the values in the new column based on the day names from the 'date' column
UPDATE sales
SET day_name = DAYNAME(date);


-- Step 3: Verify the changes
SELECT monthname(date)
FROM sales;
 
 ALTER TABLE sales
 ADD column month_name VARCHAR(20);

UPDATE sales
SET month_name = monthname(date);
 
Select * from sales;


-- How many unique cities does the data have?

Select distinct(city) from sales;

-- In which city is each branch?-- 

Select distinct(branch) , city from sales;

-- Product Based Question-- 

-- How many unique product lines does the data have?-- 

Select distinct(product_line) from sales;

-- What is the most common payment method?--
Select payment,count(payment) FROM sales
GROUP BY paymen
Order by payment ASC
limit 1;

-- What is the most selling product line?--
 SELECT product_line, sum(quantity) AS max_quantity FROM sales
GROUP BY product_line
HAVING SUM(quantity)
order by  max_quantity desc
limit 5;

-- What is the total revenue by month?--
SELECT SUM(total) AS total_sales,month_name FROM sales 
group by month_name;

-- What month had the largest COGS?--  
SELECT sum(cogs),month_name FROM sales
group by month_name
Order by SUM(cogs) desc ;

-- What product line had the largest revenue?-- 
SELECT sum(total),product_line FROM sales
group by product_line
Order by SUM(total) desc limit 1;

-- What is the city with the largest revenue?
select city , Sum(total) from sales
Group by city
order by sum(total) DESC 
limit 1 ;


-- What product line had the largest VAT?
ALTER TABLE sales
RENAME COLUMN tax_pct to VAT;
select  product_line , Sum(VAT) from sales
Group by product_line
order by sum(VAT) DESC 
limit 1 ;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales 
SELECT AVG(quantity) AS avg_qnty
FROM sales;
SELECT product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender
SELECT gender , product_line , count(gender) as cnt FROM sales
group by gender , product_line
ORDER BY cnt DESC;

-- What is the average rating of each product line
SELECT ROUND(AVG(rating), 2) as avg_rating,product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Number of sales made in each time of the day per weekday-- 
SELECT time_of_day,COUNT(*) AS total_sales FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT customer_type, sum(total) as revenue FROM sales
group by customer_type
order by revenue desc; 

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city , sum(VAT) as total_vat FROM sales
group by city 
order by total_vat desc
limit 1;

-- Which customer type pays the most in VAT?
SELECT  customer_type, sum(VAT) as revenue_vat FROM sales
group by customer_type
order by revenue_vat desc; 

-- How many unique customer types does the data have? 
SELECT distinct customer_type FROM sales;

-- How many unique payment methods does the data have?
SELECT distinct payment FROM sales;

-- What is the most common customer type?
SELECT customer_type, count(*) as count FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
Select customer_type , sum(quantity) as quantity_bought from sales
group by(customer_type) 
order by customer_type asc ;

-- What is the gender of most of the customers?
SELECT gender,COUNT(*) as gender_cnt FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT gender,COUNT(*) as gender_cnt FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
Select Day_of_time , avg(rating) as rate from sales
group by Day_of_time
order by rate desc ;

-- Which day of the week has the best average ratings per branch?
SELECT day_name,COUNT(day_name) total_sales FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;  

-- Number of sales made in each time of the day per weekday 
SELECT Day_of_time,COUNT(*) AS total_sales FROM sales
WHERE day_name = "Sunday"
GROUP BY Day_of_time
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours


-- Which of the customer types brings the most revenue?
SELECT customer_type,SUM(total) AS total_revenue FROM sales
GROUP BY customer_type
ORDER BY total_revenue;


-- END OF REPORT-- 
