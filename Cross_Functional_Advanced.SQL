--================================================================================================================================================================
--*************************************************📊 Cross-Functional/Advanced 📊*******************************************************************************
--================================================================================================================================================================



--What's the total time from order to delivery, end-to-end?

SELECT
    ROUND(
        AVG(actual_delivery_date - order_date),
        2
    ) AS total_time_days
FROM deliveries
WHERE order_date IS NOT NULL
  AND actual_delivery_date IS NOT NULL;




/*
📊 Output Purpose

Shows the average end-to-end delivery time from the
order date to the actual delivery date, helping measure
overall order fulfillment speed.

*/

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=


  -- 36. Which high-demand products are frequently out of stock?

SELECT
    p.product_id,
    p.product_name,
    SUM(i.stock_sold) AS total_stock_sold,
    SUM(
        CASE
            WHEN i.closing_stock = 0 THEN 1
            ELSE 0
        END
    ) AS out_of_stock_count
FROM products p
INNER JOIN inventory i
    ON p.product_id = i.product_id
GROUP BY
    p.product_id,
    p.product_name
HAVING
    SUM(CASE WHEN i.closing_stock = 0 THEN 1 ELSE 0 END) > 0
ORDER BY
    total_stock_sold DESC,
    out_of_stock_count DESC;


	/*
📊 Output Purpose

Shows high-demand products that have experienced stock-outs,
along with their total quantity sold and number of
out-of-stock occurrences.

Helps identify products with high demand that frequently
run out of stock, supporting better inventory planning.
*/




--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=





--37. What's our margin between purchase cost and selling price per product?

SELECT
    product_id,
    product_name,
    unit_cost AS purchase_cost,
    selling_price,
    (selling_price - unit_cost) AS margin
FROM products
ORDER BY margin DESC;


/*
📊 Output Purpose

Shows the purchase cost, selling price, and margin for
each product, helping identify products with higher
profit potential.
*/





--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=





--38. What's the most popular product category per customer segment?
WITH Product_detail AS(
SELECT  p.category_name, c.customer_segment , SUM(s.sales_amount) AS Total_sales_amount , 
ROW_NUMBER() OVER(PARTITION BY  c.customer_segment ORDER BY SUM(s.sales_amount) DESC ) AS RANK_NUMBER
FROM products p
INNER JOIN sales s
ON p.product_id = s.product_id
INNER JOIN customers c
ON s.customer_id = c.customer_id
GROUP BY p.category_name, c.customer_segment
)
SELECT customer_segment ,category_name ,Total_sales_amount, RANK_NUMBER
FROM Product_detail
WHERE RANK_NUMBER = 1




/*
📊 Output Purpose

Shows the most popular product category for each customer
segment based on the highest total sales amount.

*/



--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=





--39. How does revenue compare year-over-year?
WITH yearly_revenue AS(
	SELECT  EXTRACT( YEAR FROM order_date) AS years,  SUM(sales_amount) AS total_sales_amount FROM sales
	GROUP BY  EXTRACT( YEAR FROM order_date) 
)
,
previous_sales AS(
	SELECT years , total_sales_amount,
	LAG(total_sales_amount) OVER(ORDER BY years) AS previous_year_sales
	FROM yearly_revenue
)

	SELECT years ,total_sales_amount, previous_year_sales ,
	ROUND((((total_sales_amount - previous_year_sales) * 100) / NULLIF(previous_year_sales , 0)),2) AS Growth_precentage
	FROM previous_sales

/*
📊 Output Purpose

Shows yearly revenue, previous year's revenue, and
year-over-year growth percentage to measure revenue
growth or decline over time.

*/




--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=




-- 40. What's the 3-month moving average of revenue (trend smoothing)?

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales_amount) AS total_revenue
    FROM sales
    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT
    TO_CHAR(month, 'MM-YYYY') AS months,
    total_revenue,

    ROUND(
        AVG(total_revenue) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average

FROM monthly_revenue
ORDER BY month;



/*
📊 Output Purpose

Shows monthly revenue along with its 3-month moving average
to smooth short-term fluctuations and identify the underlying
revenue trend over time.

*/





--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=





-- Which warehouse is most profitable after delivery costs?
WITH warehouse_profit AS (
    SELECT
        s.warehouse_id,
        SUM(
            (p.selling_price - p.unit_cost) * s.quantity
        ) AS gross_profit
    FROM sales s
    INNER JOIN products p
        ON s.product_id = p.product_id
    GROUP BY s.warehouse_id
),
warehouse_delivery AS (
    SELECT
        warehouse_id,
        SUM(delivery_cost) AS delivery_cost
    FROM deliveries
    GROUP BY warehouse_id
)
SELECT
    wp.warehouse_id,
    ROUND(wp.gross_profit, 2) AS gross_profit,
    COALESCE(wd.delivery_cost, 0) AS delivery_cost,
    ROUND(
        wp.gross_profit - COALESCE(wd.delivery_cost, 0),
        2
    ) AS profit_after_delivery_cost
FROM warehouse_profit wp
LEFT JOIN warehouse_delivery wd
    ON wp.warehouse_id = wd.warehouse_id
ORDER BY profit_after_delivery_cost DESC
LIMIT 1;



/*
📊 Output Purpose

Identifies the most profitable warehouse after deducting
delivery costs from gross profit.

The warehouse with the highest profit after delivery costs
is shown as the top-performing warehouse.
*/-demand products are frequently out of stock?
