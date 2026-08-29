--================================================================================================================================================================
--*****************************************************📊 Product & Category Analysis 📊*************************************************************************
--================================================================================================================================================================

--7. Which are the top 10 best-selling products by revenue?

SELECT p.product_id, p.product_name , SUM(s.sales_amount) AS product_revenue  FROM products p
INNER JOIN sales s
ON p.product_id = s.product_id
GROUP BY  p.product_id, p.product_name
ORDER BY product_revenue DESC LIMIT 10;


/*
📊 Output:
Top 10 products ranked by total revenue generated, from highest to lowest.
*/



--****************************************************************************************************************************************************************

-- 8. Which category generates the most revenue and profit margin?

WITH category_sales AS(
SELECT p.category_name, SUM(s.sales_amount) AS Category_revenue ,SUM(s.profit) AS Profit  FROM products p
INNER JOIN sales s
ON p.product_id = s.product_id
GROUP BY p.category_name
)

SELECT
category_name,
Category_revenue,
Profit,
ROUND(((Profit / Category_revenue) * 100),2) as profit_margin
FROM category_sales
ORDER BY Category_revenue DESC,profit_margin DESC LIMIT 1;

/*
📊 Output

Highest-revenue category along with its total revenue, profit, and profit margin.
*/

--****************************************************************************************************************************************************************

-- 9. Which products have never been sold (dead stock)?

SELECT p.product_id, p.product_name FROM products p
LEFT JOIN sales s
ON p.product_id = s.product_id
WHERE s.product_id IS NULL ;

/*
📊 Output
List of products with no sales records (dead stock).
*/

--****************************************************************************************************************************************************************


-- 10. How do products rank within their category by revenue?

WITH product_data_by_category  AS(
SELECT p.product_id, p.product_name, p.category_name , SUM(s.sales_amount) AS tatal_revenue FROM products p
INNER JOIN sales s
ON p.product_id = s.product_id
GROUP BY  p.product_id, p.product_name, p.category_name
)

SELECT product_id, product_name, category_name ,tatal_revenue,
RANK() OVER(PARTITION BY category_name ORDER BY tatal_revenue DESC ) AS Rank_category_wise_product
FROM product_data_by_category

/*
📊 Output
Category-wise product revenue ranking.
*/

--****************************************************************************************************************************************************************

--11. Are we selling any products at a loss after discount?

SELECT 
    p.product_id,
    p.product_name,
    p.unit_cost,
    s.unit_price,
    s.discount,
    ROUND(s.unit_price * (1 - s.discount), 2) AS discounted_unit_price
FROM products p
INNER JOIN sales s
    ON p.product_id = s.product_id
WHERE ROUND(s.unit_price * (1 - s.discount), 2) < p.unit_cost;

/*
📊 Output
Products sold below their unit cost after discount, along with their cost, selling price, discount, and discounted selling price.
*/



