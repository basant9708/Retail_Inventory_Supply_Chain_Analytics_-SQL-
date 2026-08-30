--==================================================================================================================================================================
--*************************************************📊 Supplier & Purchase Analysis 📊*******************************************************************************
--==================================================================================================================================================================


-- 1. Which suppliers do we spend the most with?

SELECT
    s.supplier_id,
    s.supplier_name,
    SUM(p.total_cost) AS total_spend
FROM suppliers s
INNER JOIN purchases p
    ON s.supplier_id = p.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY
    total_spend DESC;

/*
📊 Output Purpose

Shows suppliers ranked by total purchase spending,
with the highest-spend suppliers appearing first.
*/


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-


-- 25. Which suppliers deliver on time most consistently?

	SELECT
    s.supplier_id,
    s.supplier_name,

    COUNT(p.purchase_id) AS total_deliveries,

    SUM(
        CASE
            WHEN p.actual_delivery_date <= p.expected_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_deliveries,

    ROUND(
        SUM(
            CASE
                WHEN p.actual_delivery_date <= p.expected_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(p.purchase_id),
        2
    ) AS on_time_delivery_rate

FROM suppliers s
INNER JOIN purchases p
    ON s.supplier_id = p.supplier_id

WHERE p.actual_delivery_date IS NOT NULL
  AND p.expected_delivery_date IS NOT NULL

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY on_time_delivery_rate DESC;

/*
📊 Output Purpose

Shows suppliers ranked by their on-time delivery rate,
with the most consistently on-time suppliers appearing first.

*/


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-


--26. What's the average delivery delay per supplier?


SELECT
    s.supplier_id,
    s.supplier_name,

    ROUND(
        AVG(
            p.actual_delivery_date - p.expected_delivery_date
        ),
        2
    ) AS average_delivery_delay_days

FROM suppliers s
INNER JOIN purchases p
    ON s.supplier_id = p.supplier_id

WHERE p.actual_delivery_date > p.expected_delivery_date

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY
    average_delivery_delay_days DESC;


/*
📊 Output Purpose

Shows suppliers ranked by their average delivery delay in days,
with suppliers having the highest average delay appearing first.

*/



--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

---- 27. What % of purchase orders are pending/delivered/cancelled?

SELECT
    purchase_status,
    COUNT(purchase_id) AS total_orders,

    ROUND(
        COUNT(purchase_id) * 100.0
        / SUM(COUNT(purchase_id)) OVER (),
        2
    ) AS percentage

FROM purchases

GROUP BY purchase_status

ORDER BY percentage DESC;

/*
📊 Output Purpose

Shows the percentage of purchase orders in each status,
including Pending, Delivered, and Cancelled orders.

*/



--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

-- -- 28. Which suppliers offer the best lead times per category?

WITH supplier_category_lead_time AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        p.primary_category,

        ROUND(
            AVG(
                pch.actual_delivery_date - pch.purchase_date
            ),
            2
        ) AS avg_lead_time_days

    FROM suppliers s

    INNER JOIN purchases pch
        ON s.supplier_id = pch.supplier_id

    INNER JOIN products p
        ON pch.product_id = p.product_id

    WHERE pch.actual_delivery_date IS NOT NULL

    GROUP BY
        s.supplier_id,
        s.supplier_name,
        p.primary_category
)

SELECT
    supplier_id,
    supplier_name,
    primary_category,
    avg_lead_time_days
FROM supplier_category_lead_time
ORDER BY
    primary_category,
    avg_lead_time_days ASC;


	/*
📊 Output Purpose

Shows suppliers ranked by their average lead time within
each product category, with the fastest suppliers appearing
first for each category.

*/


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

-- 29. What's our monthly purchase spend trend?

SELECT
    DATE_TRUNC('month', purchase_date) AS month,
    SUM(total_cost) AS monthly_purchase_spend
FROM purchases
GROUP BY DATE_TRUNC('month', purchase_date)
ORDER BY month;



/*
📊 Output Purpose

Shows the total purchase spending for each month,
displaying the monthly purchase spend trend over time.

*/
