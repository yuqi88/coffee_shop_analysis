
/*
Time-based analysis (revenues & sales)
    Q1: When are the peak sales periods (orders per hour)?
    Q2: When are the peak sales periods (AOV per hour)?
        - When are the peak sales periods (revenue per hour)?
    Q3: Are weekends different from weekdays?
        - order per hour
        - revenue per hour
        - AOV: average order value = total revenue /total transactions
    Q4: Other periods of time to compare: valentine's week/weekday/weekend
    Q5: Orders per day: hit goal or not, see which day has lesser sales

    B1: opteration hours change, staffing + break schedule, schedule prep time, cut down customer wait time.
    B2: Busy does not always mean profitable. Which periods need revenue improvement? (marketing focus + staffing priority)
    B3:  - 
    B4:  - 
*/

-- Q1: When are the peak sales periods (orders per hour)?
SELECT 
    EXTRACT(HOUR FROM ordered_at) AS ordered_at_hour,
    count(DISTINCT order_id) AS feb_total_order_count_per_hour
FROM orders
GROUP BY 
    ordered_at_hour;

-- Q2: When are the peak sales periods (AOV per hour)?
/* 
    AOV = total revenue/ number of orders.
    - tables: orders, products_n_prices
*/
SELECT 
    EXTRACT(HOUR FROM o.ordered_at) AS ordered_at_hour,
    ROUND(
        SUM(o.quantity * pp.price) *1.0 / COUNT(DISTINCT o.order_id),
        2
    ) AS feb_aov
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id
GROUP BY 
    ordered_at_hour;

-- Q2*: When are the peak sales periods (Renvenue per hour)?
SELECT 
    EXTRACT(HOUR FROM o.ordered_at) AS ordered_at_hour,
    ROUND(
        SUM(o.quantity * pp.price),
        2
    ) AS feb_rev
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id
GROUP BY 
    ordered_at_hour
ORDER BY ordered_at_hour;


-- Q3-1 : Are weekends different from weekdays? (order per hour)
SELECT 
    CASE
        WHEN EXTRACT(DOW FROM ordered_at) IN (6,0) THEN 'weekend'
        ELSE 'weekday'
    END AS day_type,
    EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
    ROUND(COUNT(DISTINCT order_id)*1.0/ COUNT(DISTINCT ordered_at::DATE), 2) AS avg_order_count
FROM orders
GROUP BY
    day_type,
    order_at_hour
;

-- Q3-2 : Are weekends different from weekdays? (AOV per hour)
SELECT 
    CASE
        WHEN EXTRACT(DOW FROM ordered_at) IN (6,0) THEN 'weekend'
        ELSE 'weekday'
    END AS day_type,
    EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
    ROUND(
        SUM(o.quantity * pp.price) *1.0 / COUNT(DISTINCT o.order_id),
        2
    ) AS aov
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id
GROUP BY
    day_type,
    order_at_hour
;

-- Q3-3: Are weekends different from weekdays? (revenue per hour)
--NOTE: manual pivot table
WITH piv_rev AS (
    SELECT 
        CASE
            WHEN EXTRACT(DOW FROM ordered_at) IN (6,0) THEN 'weekend'
            ELSE 'weekday'
        END AS day_type,
    EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
    ROUND(
        SUM(o.quantity * pp.price) *1.0,
        2
    ) AS rev
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    GROUP BY
        day_type,
        order_at_hour
)SELECT 
    order_at_hour,
    SUM(CASE WHEN day_type = 'weekday' THEN rev ELSE 0 END) AS "weekday",
    SUM(CASE WHEN day_type = 'weekend' THEN rev ELSE 0 END) AS "weekend"  
FROM piv_rev
GROUP BY order_at_hour
ORDER BY order_at_hour;


-- Q4-1: valentine's day/weekend/week (order per hour)
-- Valentine's day (sat), (sun) weekend businer than other weekends?
-- daily avergage order counts (v-day vs v-weekend )
WITH
    v_day_avg_orders AS(
        SELECT 
            EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
            COUNT(DISTINCT order_id) AS val_orders
        FROM orders
        WHERE EXTRACT(DAY FROM ordered_at) = 14
        GROUP BY order_at_hour
    ),v_weekend_avg_orders AS (
        SELECT 
            EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
            ROUND(
                COUNT(DISTINCT order_id) *1.0/COUNT(DISTINCT ordered_at::DATE),
                2
            )AS val_wkend_avg_orders
        FROM orders
        WHERE EXTRACT(DAY FROM ordered_at) IN (14, 15)
        GROUP BY order_at_hour
    ),other_weekend_avg_orders AS (
        SELECT 
            EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
            ROUND(
                COUNT(DISTINCT order_id) *1.0/COUNT(DISTINCT ordered_at::DATE),
                2
            )AS other_wkend_avg_orders
        FROM orders
        WHERE 
            EXTRACT (DOW FROM ordered_at) IN (6, 0) AND
            EXTRACT(DAY FROM ordered_at) NOT IN (14, 15)
        GROUP BY order_at_hour
)SELECT
    vdo.order_at_hour,
    vdo.val_orders,
    vwo.val_wkend_avg_orders,
    owo.other_wkend_avg_orders
FROM v_day_avg_orders vdo
JOIN v_weekend_avg_orders vwo ON vdo.order_at_hour = vwo.order_at_hour
JOIN other_weekend_avg_orders owo ON vdo.order_at_hour = owo.order_at_hour
;
-- Valentine's weekdays also busier than other weekdays?
-- avg orders (valentine's weekdays vs other weekdays in Feb)
WITH
    val_weekdays AS (
        SELECT 
            EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
            ROUND(
                COUNT(DISTINCT order_id) *1.0/COUNT(DISTINCT ordered_at::DATE),
                2
            )AS avg_orders_v_wkdays
        FROM orders
        WHERE EXTRACT(DAY FROM ordered_at) BETWEEN 9 AND 13 -- monday to friday
        GROUP BY order_at_hour
    ), other_weekdays AS (
        SELECT 
            EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
            ROUND(
                COUNT(DISTINCT order_id) *1.0/COUNT(DISTINCT ordered_at::DATE),
                2
            )AS avg_orders_other_wkdays
        FROM orders
        WHERE 
            (EXTRACT(DOW FROM ordered_at) IN (1,2,3,4,5)) AND -- monday to friday
            (EXTRACT(DAY FROM ordered_at) NOT BETWEEN 9 AND 13 ) -- not the valentine's weekdays
        GROUP BY order_at_hour
) SELECT 
    vw.order_at_hour,
    vw.avg_orders_v_wkdays,
    ows.avg_orders_other_wkdays
FROM val_weekdays vw
JOIN other_weekdays ows ON vw.order_at_hour = ows.order_at_hour
;

-- Q4-2: valentine's week/weekday/weekend (avo per hour)
-- Valentine's day (sat), (sun) weekend earning > than other weekends? (avo)
-- daily avergage order counts (v-day vs v-weekend )

WITH payments AS (
    SELECT 
        o.order_id,
        o.ordered_at,
        SUM(o.quantity*pp.price) AS payment
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    GROUP BY 
        o.order_id,
        o.ordered_at
)SELECT
    EXTRACT(HOUR FROM p.ordered_at) AS order_at_hour,
    ROUND(
        SUM(p.payment) FILTER(WHERE EXTRACT(DAY FROM p.ordered_at) = 14)*1.0
        /
        COUNT(p.order_id) FILTER(WHERE EXTRACT(DAY FROM p.ordered_at) = 14),
        2
    ) AS v_avo,    
        ROUND(
        SUM(p.payment) FILTER(WHERE EXTRACT(DAY FROM p.ordered_at) IN (14, 15))*1.0
        /
        COUNT(p.order_id) FILTER(WHERE EXTRACT(DAY FROM p.ordered_at)  IN (14, 15)),
        2
    ) AS v_wkend_avo,       
    ROUND(
        SUM(p.payment)*1.0/COUNT(p.order_id),
        2
    ) AS feb_avo
FROM payments p
GROUP BY order_at_hour
ORDER BY order_at_hour;

-- Q5: total orders in Feb?
SELECT
    COUNT(DISTINCT order_id) AS order_count_feb
FROM orders
