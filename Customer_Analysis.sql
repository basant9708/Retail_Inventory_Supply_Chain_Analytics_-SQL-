-- 1.	How many customers do we have by state and gender?

select state, gender, count(customer_id) as number_of_customer FROM customers
GROUP BY  state, gender
ORDER BY STATE;


/*📊 Output:
Provides the number of customers for each state and gender combination.
*/


-- 2.	What's the monthly trend of new customer registrations?
SELECT TO_CHAR(DATE_TRUNC('MONTH' ,registration_date),'MM-YYYY') AS registration_monthly_trend ,COUNT(customer_id) FROM customers
GROUP BY TO_CHAR(DATE_TRUNC('MONTH' ,registration_date),'MM-YYYY')
ORDER BY registration_monthly_trend;


/*
📊 Output:

Monthly breakdown of newly registered customers, showing the number of customers registered in each month.
*/



-- 3.	Who are our top 10 customers by revenue?

SELECT c.customer_id , c.customer_name , SUM(s.sales_amount) AS Total_Sales FROM customers c
INNER JOIN sales s
ON c.customer_id = s.customer_id
GROUP BY c.customer_id , c.customer_name
ORDER BY Total_Sales DESC LIMIT 10;

/*
📊 Output
Output: Top 10 customers ranked by their total revenue contribution, from highest to lowest.
*/



-- 4.	Which customer segment contributes the most revenue (%)?
WITH customer_segment_sales  AS(
SELECT c.customer_segment , SUM(s.sales_amount) AS total_revenue FROM customers c
INNER JOIN sales s
ON c.customer_id = s.customer_id
GROUP BY c.customer_segment
ORDER BY total_revenue DESC
)

SELECT customer_segment, 
total_revenue, 
ROUND(((total_revenue * 100 ) / SUM(total_revenue) OVER()),2)  AS revenue_precentage
FROM customer_segment_sales 
ORDER BY revenue_precentage DESC LIMIT 1;

/*
📊 Output
Output: The customer segment with the highest revenue contribution (%), along with its total revenue and percentage of overall revenue.
*/



-- 5.	What's the lifetime value (CLV) of each customer?
SELECT  c.customer_id , c.customer_name , SUM(s.sales_amount) AS total_revenue 
FROM customers c
INNER JOIN sales s
ON  c.customer_id =  s.customer_id
GROUP BY c.customer_id , c.customer_name
ORDER BY total_revenue DESC

/*
📊 Output
Customer-wise total sales revenue (CLV).
*/



-- 6.	What % of customers are repeat buyers vs one-time?
WITH customer_orders AS(
SELECT c.customer_id , c.customer_name ,COUNT(s.customer_id) AS number_of_customer FROM customers c
INNER JOIN sales s
ON  c.customer_id =  s.customer_id
GROUP BY c.customer_id , c.customer_name
ORDER BY number_of_customer
)
,
customer_type  AS(
SELECT customer_id, customer_name, number_of_customer,
CASE
WHEN number_of_customer = 1 THEN 'One-Time Buyer'
ELSE 'Repeat Buyer' 
END AS customer_type
FROM customer_orders
)

SELECT customer_type , 
COUNT(customer_id) AS number_of_customer ,
ROUND((COUNT(customer_id) * 100.0 / SUM(COUNT(customer_id)) OVER()),2) AS customer_percentage
from customer_type
group by customer_type ;

/*
📊 Output
Customer purchase type with the number and percentage of customers in each group.
*/







