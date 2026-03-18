---Monday coffee---Data Analytics

SELECT * FROM city;

----Reports & Data Analysis

---Q1 Coffee consumers count
--How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
  city_name,
  (population * 0.25) as coffee_consumers,
  city_rank
FROM city
ORDER BY 2 DESC;

---Q2 Total revenue from coffee sales
--What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT *,
   EXTRACT (YEAR FROM sales_date) as year,
   EXTRACT (quarter FROM sales_date) as qtr
FROM sales
WHERE
    EXTRACT (YEAR FROM sales_date) = 2023
	AND
	EXTRACT (quarter FROM sales_date)= 4;
	
SELECT
    ci.city_name,
	SUM(s.total) as total_revenue
FROM sales as s
JOIN customers as c
ON s.customers_id=c.customers_id
JOIN city as ci
ON ci.city_id = c.city_id
WHERE 
    EXTRACT (YEAR FROM s.sales_date) = 2023
	AND
	EXTRACT (quarter FROM s.sales_date)= 4
GROUP BY 1
ORDER BY 2 DESC;

---Q3 Sales count for each product
--How many units of each coffee product have been sold?
SELECT 
    p.product_name,
	COUNT(s.sales_id) as total_orders
FROM products as p
LEFT JOIN 
sales as s
ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;

---Q4 Average Sales amount per city
--What is the average sales amount per customer in each city?

--total sales in each city and No of customers in those cities
SELECT 
    ci.city_name,
	SUM(s.total) as total_sales,
	COUNT (DISTINCT s.customers_id) as total_customers,
	SUM(s.total)/COUNT(DISTINCT s.customers_id) as average_sales_per_customer
FROM sales as s
JOIN customers as c
ON s.customers_id = c.customers_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;

---Q5 City Population and Coffee Consumers
--Provide a list of cities along with their populations and estimated coffee consumers.
--return city_name, total current_customers, estimated coffee consumers (25%)
SELECT 
    city_name,
	population * 0.25 as coffee_consumers
FROM city;

WITH city_table as 
(   
   SELECT 
    city_name,
	population * 0.25 as coffee_consumers
   FROM city
 ),
 customers_table
 AS
 (
    SELECT
	   ci.city_name,
	   COUNT(DISTINCT c.customers_id) as unique_customers
	 FROM sales as s
	 JOIN customers as c
	 ON c.customers_id = s.customers_id
	 JOIN city as ci
	 ON ci.city_id = c.city_id
	 GROUP BY 1
)
SELECT 
    city_table.city_name,
	city_table.coffee_consumers as coffee_consumers,
	customers_table.unique_customers
FROM city_table 
JOIN
customers_table 
ON city_table.city_name = customers_table.city_name;

---Q6 Top selling Products by city
--What are the top 3 selling products in each city based on sales volume?
SELECT 
    ci.city_name,
	p.product_name,
	COUNT(s.sales_id) as total_orders,
	DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sales_id)DESC) as rank
FROM sales as s
JOIN products as p
ON s.product_id = p.product_id
JOIN customers as c 
ON c.customers_id = s.customers_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1,2;

---Q7 Customer segmentation by city
--How many unique customers are there in each city who have purchased coffee products?
SELECT *
FROM city as ci
LEFT JOIN customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customers_id = c.customers_id
JOIN products as p 
ON p.product_id = s.product_id;

SELECT 
    ci.city_name,
	COUNT (DISTINCT c.customers_id) as unique_customers
FROM city as ci
LEFT JOIN customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customers_id = c.customers_id
WHERE 
    s.product_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
GROUP BY 1;

---Q8 Average Sale Vs Rent
--Find each city and their average sale per customer and average rent per customer.
--average sale
SELECT 
    ci.city_name,
	COUNT(DISTINCT s.customers_id) as total_customers,
	SUM(s.total)/COUNT(DISTINCT s.customers_id) as average_sale_per_customer
FROM sales as s
JOIN customers as c 
ON s.customers_id = c.customers_id
JOIN city as ci 
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;
-- Average rent
--city and total rent/total customers
WITH city_table
AS
(
   SELECT
       ci.city_name,
	   COUNT(DISTINCT s.customers_id) as total_customers,
	   SUM(s.total) as total_revenue,
	   COUNT(DISTINCT s.customers_id) as average_sale_per_customer
   FROM sales as s
   JOIN customers as c
   ON s.customers_id = c.customers_id
   JOIN city as ci 
   ON ci.city_id = c.city_id
   GROUP BY 1
   ORDER BY 2 DESC
),
city_rent 
AS 
(SELECT 
     city_name,
	 estimated_rent
 FROM city
)

SELECT 
     cr.city_name,
	 cr.estimated_rent,
	 ct.total_customers,
	 ct.average_sale_per_customer,
	 cr.estimated_rent/ct.total_customers as average_rent_per_customer
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 4 DESC;

---Q9 Monthly Sales Grownth
--Sales grownth rate: calculate the percentage grownth (or decline) in sales over different time periods (monthly) by each city 
SELECT *
FROM sales as s
JOIN customers as c
ON c.customers_id = s.customers_id
JOIN city as ci
ON ci.city_id = c.city_id;
--monthly sales
SELECT 
     ci.city_name,
	 EXTRACT (MONTH FROM sales_date) as month,
	 EXTRACT (YEAR FROM sales_date) as Year,
	 SUM (s.total) as total_sale
FROM sales as s 
JOIN customers as c 
ON c.customers_id = s.customers_id
JOIN city as ci 
ON ci.city_id = c.city_id
GROUP BY 1,2,3
ORDER BY 1,3,2;

WITH monthly_sales 
AS 
(
  SELECT 
     ci.city_name,
	 EXTRACT (MONTH FROM sales_date) as month,
	 EXTRACT (YEAR FROM sales_date) as Year,
	 SUM (s.total) as total_sale
FROM sales as s 
JOIN customers as c 
ON c.customers_id = s.customers_id
JOIN city as ci 
ON ci.city_id = c.city_id
GROUP BY 1,2,3
ORDER BY 1,3,2
),
grownth_ratio 
AS
(SELECT 
     city_name,
	 month,
	 year,
	 total_sale as current_month_sale,
	 LAG(total_sale,1) OVER(PARTITION BY city_name ORDER BY year,month) as last_month_sale
 FROM monthly_sales
)
SELECT 
    city_name,
	month,
	year,
	current_month_sale,
	last_month_sale,
	((current_month_sale - last_month_sale) / last_month_sale) * 100  as grownth_ratio
FROM grownth_ratio
WHERE last_month_sale is not null;

---Q10 Market Potential Analysis
--Identify top 3 city based on highest sales, return city name, total sale,total rent, total customers, estimated coffee consumer
SELECT 
    ci.city_name,
	COUNT(DISTINCT s.customers_id) as total_customers,
	SUM(s.total)/COUNT(DISTINCT s.customers_id) as average_sale_per_customer
FROM sales as s
JOIN customers as c 
ON s.customers_id = c.customers_id
JOIN city as ci 
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;
-- Average rent
--city and total rent/total customers
WITH city_table
AS
(
   SELECT
       ci.city_name,
	   COUNT(DISTINCT s.customers_id) as total_customers,
	   SUM(s.total) as total_revenue,
	   COUNT(DISTINCT s.customers_id) as average_sale_per_customer
   FROM sales as s
   JOIN customers as c
   ON s.customers_id = c.customers_id
   JOIN city as ci 
   ON ci.city_id = c.city_id
   GROUP BY 1
   ORDER BY 2 DESC
),
city_rent 
AS 
(SELECT 
     city_name,
	 population * 0.25 as estimated_coffee_consumers,
	 estimated_rent
 FROM city
)

SELECT 
     cr.city_name,
	 total_revenue,
	 estimated_coffee_consumers,
	 cr.estimated_rent,
	 ct.total_customers,
	 ct.average_sale_per_customer,
	 cr.estimated_rent/ct.total_customers as average_rent_per_customer
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC;

---Recomendation 
--city 1: Pune
--    1.Average rent per customer is very less
--    2. Highest total revenue
--    3. Average sale per customer is high
--city 2: Delhi
--    1. Highest estimated coffee consumer which is 7.7m
--    2. Highest total customer which is 68
--    3. Average rent per customer 330(under 500)
--city 3: Jaipur
--    1. Highestcustomer number which is 69
--    2. Average rent per customer is very less 156
--    3. Average sale per customer is good which is 11.6k