--=============================================================================================================================================================
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*📊 InventoryAnalysis 📊-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
--=============================================================================================================================================================


--1. Which warehouse/product combos have the most damaged stock?


SELECT w.warehouse_id,	w.warehouse_name, p.product_id,	p.product_name, SUM(i.damaged_stock) AS Damage_stocks  FROM warehouses w
INNER JOIN  inventory i
ON w.warehouse_id = i.warehouse_id
INNER JOIN products p
ON p.product_id = i.product_id
GROUP BY w.warehouse_id, w.warehouse_name, p.product_id,	p.product_name
ORDER BY Damage_stocks DESC;

/*📊 Output

Displays warehouse-product combinations ranked by total damaged stock, with the most damaged stock shown first.

💼 Business Purpose

Helps identify warehouses and products with high inventory damage so management can investigate losses and improve inventory handling.
*/ 

--********************************************************************************************************************************************

--2. What's the inventory turnover ratio per product?

WITH product_cogs AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(s.quantity * p.unit_cost) AS cogs
    FROM products p
    INNER JOIN sales s
        ON p.product_id = s.product_id
    GROUP BY
        p.product_id,
        p.product_name
),

product_inventory AS (
    SELECT
        p.product_id,
        p.product_name,
        AVG(
            ((i.opening_stock + i.closing_stock) / 2.0)
            * p.unit_cost
        ) AS average_inventory_value
    FROM products p
    INNER JOIN inventory i
        ON p.product_id = i.product_id
    GROUP BY
        p.product_id,
        p.product_name
)

SELECT
    c.product_id,
    c.product_name,
    ROUND(c.cogs, 2) AS cogs,
    ROUND(i.average_inventory_value, 2) AS average_inventory_value,
    ROUND(
        c.cogs / NULLIF(i.average_inventory_value, 0),
        2
    ) AS inventory_turnover_ratio
FROM product_cogs c
INNER JOIN product_inventory i
    ON c.product_id = i.product_id
ORDER BY inventory_turnover_ratio DESC;

/*
📊 Output
Displays COGS, average inventory value, and inventory turnover ratio for each product, helping identify fast- and slow-moving inventory.
*/



--*******************************************************************************************************************************************



--3.Which products have the highest stock received? 


SELECT p.product_id , p.product_name, SUM(i.stock_received) AS received_stock  FROM  products p
INNER JOIN inVentory i
ON p.product_id = i.product_id
GROUP BY p.product_id , p.product_name
ORDER BY received_stock DESC;

/*
📊 Output Purpose

Displays products ranked by the total quantity of stock received, helping identify which products are being replenished the most.
*/

--************************************************************************************************************************************



--4. Which products have the highest stock sold?
SELECT  p.product_id , p.product_name, SUM(i.stock_sold) AS sold_stock  FROM  products p
INNER JOIN inVentory i
ON p.product_id = i.product_id
GROUP BY p.product_id , p.product_name
ORDER BY sold_stock DESC;
/*
📊 Output Purpose
Displays products ranked by the total quantity sold, helping identify the highest-demand / fast-moving products.
*/



--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 5. Which products have the highest damage rate?

SELECT
    p.product_id,
    p.product_name,
    SUM(i.damaged_stock) AS damaged_stock,
    SUM(i.opening_stock + i.stock_received) AS total_stock,

    ROUND(
        SUM(i.damaged_stock) * 100.0
        / NULLIF(
            SUM(i.opening_stock + i.stock_received),
            0
        ),
        2
    ) AS damage_rate_percentage

FROM products p

INNER JOIN inventory i
    ON p.product_id = i.product_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY
    damage_rate_percentage DESC;


	/*
📊 Output
Product-wise damage rate percentage.

Identifies products with the highest percentage of damaged stock
to help reduce inventory losses and improve stock handling.
*/


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- 6. Which warehouses have the highest stock wastage?

SELECT
w.warehouse_id,
w.warehouse_name,
SUM(i.damaged_stock) AS total_wastage
FROM warehouses w
INNER JOIN inventory i
ON w.warehouse_id = i.warehouse_id
GROUP BY
w.warehouse_id,
w.warehouse_name
ORDER BY total_wastage DESC;

/*
📊 Output
Warehouse-wise total damaged stock.

🎯 Purpose
Identifies warehouses with the highest stock wastage
to help management reduce inventory losses.
*/
