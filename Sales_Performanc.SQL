--===============================================================================================================================================================
--********************************************************************📊 Sales Performanc 📊********************************************************************
--===============================================================================================================================================================


--12. What's the monthly revenue and profit trend?

SELECT TO_CHAR(DATE_TRUNC('MONTH',order_date),'MM-YYYY') AS Month_Year, SUM(sales_amount) AS Total_revenue , SUM(profit) AS total_profit FROM sales 
GROUP BY TO_CHAR(DATE_TRUNC('MONTH',order_date),'MM-YYYY')

/*
📊 Output
Monthly revenue and profit breakdown.
*/

--****************************************************************************************************************************************************************

-- 13. What's the month-over-month revenue growth rate?
WITH month_wise_sales AS(
SELECT 
DATE_TRUNC('MONTH',order_date) AS months,
TO_CHAR(DATE_TRUNC('MONTH',order_date),'MM-YYYY') AS Month_Year, SUM(sales_amount) AS Total_revenue FROM sales
GROUP BY DATE_TRUNC('MONTH',order_date),
TO_CHAR(DATE_TRUNC('MONTH',order_date),'MM-YYYY')
)
, previous_month AS(
SELECT Month_Year ,Total_revenue ,
LAG(Total_revenue) OVER( ORDER BY MONTHS ) AS Previous_month
FROM month_wise_sales
)

SELECT Month_Year, Total_revenue ,Previous_month ,
(Total_revenue - Previous_month ) as Gowth_rate,
ROUND(((Total_revenue - Previous_month ) * 100 / nullif(Previous_month, 0)),2) AS Growth_rate_Precentage
FROM  previous_month;


/*
📊 Output
Monthly revenue growth and percentage change from the previous month.
*/


--****************************************************************************************************************************************************************


--14. What % of orders are completed vs cancelled vs returned?
WITH order_status AS( 
SELECT order_status , COUNT(order_status) AS number_of_status FROM sales
GROUP BY order_status
)
SELECT order_status ,number_of_status , 
ROUND(((number_of_status * 100.0) / SUM(number_of_status) OVER()),2) AS precent_status FROM order_status;


/*
📊 Output
Order count and percentage breakdown by order status.
*/


--****************************************************************************************************************************************************************

--15. What's the cumulative (running total) revenue over time?

SELECT 
order_date ,
SUM(sales_amount) AS daily_revenue,
SUM(SUM(sales_amount)) OVER(ORDER BY order_date) AS running_total FROM sales
GROUP BY order_date


/*
📊 Output
Daily revenue and cumulative running total revenue.
*/

--****************************************************************************************************************************************************************  


-- 16. Which warehouse generates the most sales and profit?

SELECT w.warehouse_id, w.warehouse_name , SUM(s.sales_amount) AS sales_revenue, SUM(s.profit) AS profit  FROM warehouses w
INNER JOIN sales s
ON w.warehouse_id  = s.warehouse_id
GROUP BY  w.warehouse_id, w.warehouse_name
ORDER BY 
sales_revenue DESC profit DESC  LIMIT 1;


/*
🎯 Purpose
To identify the warehouse that generates the highest sales revenue and profit.

📊 Output
Top-performing warehouse with total sales revenue and profit.
*/


--****************************************************************************************************************************************************************

--17. How does discount % affect profit margin by category?


SELECT p.category_name , s.discount , ROUND((SUM(s.profit) / NULLIF(SUM(s.sales_amount),0)),2) * 100 AS Profit_margin  
FROM products p
INNER JOIN  sales s
ON p.product_id =  S.product_id
GROUP BY p.category_name ,s.discount
ORDER BY category_name , s.discount

/*
🎯 Purpose
To analyze how different discount levels affect profit margin across product categories.

📊 Output
Category-wise discount percentage and corresponding profit margin.
*/














