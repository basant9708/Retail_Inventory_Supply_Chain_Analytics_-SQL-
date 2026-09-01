--================================================================================================================================================================
--***************************************************************📊  Delivery/Logistics Analysis 📊**************************************************************
--================================================================================================================================================================



--1. Which delivery partner performs best (on-time %, cost)?

WITH partner AS (
    SELECT
        delivery_partner,

        COUNT(delivery_id) AS total_deliveries,

        SUM(
            CASE
                WHEN actual_delivery_date <= expected_delivery_date
                THEN 1
                ELSE 0
            END
        ) AS on_time_deliveries,

        ROUND(
            SUM(
                CASE
                    WHEN actual_delivery_date <= expected_delivery_date
                    THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(delivery_id),
            2
        ) AS on_time_percentage,

        SUM(delivery_cost) AS delivery_cost

    FROM deliveries

    WHERE expected_delivery_date IS NOT NULL
      AND actual_delivery_date IS NOT NULL

    GROUP BY delivery_partner
)

SELECT
    delivery_partner,
    total_deliveries,
    on_time_deliveries,
    on_time_percentage,
    delivery_cost,

    ROUND(
        delivery_cost * 100.0
        / SUM(delivery_cost) OVER(),
        2
    ) AS cost_percentage

FROM partner

ORDER BY on_time_percentage DESC;


/*
📊 Output Purpose

Shows each delivery partner's on-time delivery percentage
and total delivery cost, helping identify reliable and
cost-effective delivery partners.

*/


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*



--2. How long does it take to dispatch and deliver orders on average?

SELECT ROUND(AVG(actual_delivery_date - dispatch_date),2) AS orders_on_average FROM deliveries
WHERE dispatch_date IS NOT NULL AND actual_delivery_date IS NOT NULL;


/*
📊 Output Purpose

Shows the average number of days taken to deliver orders
after they are dispatched.

*/


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*




-- 3. What's the delivery status breakdown by warehouse?

SELECT
    warehouse_id,
    delivery_status,
    COUNT(delivery_id) AS total_deliveries
FROM deliveries
GROUP BY
    warehouse_id,
    delivery_status
ORDER BY
    warehouse_id,
    total_deliveries DESC;


	/*
📊 Output Purpose

Shows the number of deliveries in each delivery status
for every warehouse.

*/



--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*



-- 4. Which deliveries were late, and by how many days?

SELECT
    delivery_id,
    expected_delivery_date,
    actual_delivery_date,
    actual_delivery_date - expected_delivery_date AS late_delivery_days
FROM deliveries
WHERE actual_delivery_date > expected_delivery_date
ORDER BY late_delivery_days DESC;

/*
📊 Output Purpose

Shows all deliveries that were completed after the expected
delivery date, along with the number of days each delivery
was late.

*/


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*



-- 5. What's our monthly delivery cost trend?

SELECT
    TO_CHAR(DATE_TRUNC('month', actual_delivery_date), 'MM-YYYY') AS months,
    SUM(delivery_cost) AS delivery_cost
FROM deliveries
WHERE delivery_cost IS NOT NULL AND actual_delivery_date IS NOT NULL
GROUP BY DATE_TRUNC('month', actual_delivery_date)
ORDER BY DATE_TRUNC('month', actual_delivery_date) ASC ;


/*
📊 Output Purpose

Shows the total delivery cost incurred each month,
helping track monthly delivery cost trends over time.

*/
