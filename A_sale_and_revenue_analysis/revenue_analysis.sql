/*
    Revenue analysis
    Q0: Total revenue
    Q1: Revenue by time
        - Total revenue by weeks/months
        - Peak vs non-peak sales(revenue from selling; there are non-selling revenues. E.g. acquistion or inventment)
    Q2: Revenue by product
        - Which products generate the highest revenue?
    Q3: Revenue by product category
        - Which products categories generate the highest revenue?
    Q4: Revenue by product and traffic
        - Which products sell often but generate low revenue?

Revenue by channel
*/

-- Q1-1: feb total sales revenue: $159,301.80
/*
    - orders table, prices_n_products
*/
SELECT SUM(o.quantity * pp.price) AS feb_revenue
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id

-- Q1-2: weekly sales revenue
SELECT 
    CASE
        WHEN EXTRACT(DAY FROM o.ordered_at) < 8 THEN 1
        WHEN EXTRACT(DAY FROM o.ordered_at) BETWEEN 8 AND 14 THEN 2
        WHEN EXTRACT(DAY FROM o.ordered_at) BETWEEN 15 AND 21 THEN 3
        WHEN EXTRACT(DAY FROM o.ordered_at) BETWEEN 22 AND 28 THEN 4
        ELSE -1
    END AS week,
    SUM(o.quantity * pp.price) AS feb_revenue
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id
GROUP BY week
ORDER BY week;

-- Q1-3: Peak vs non-peak sales (part of KPI analysis)
/*
    - i choose revenue per hour
    - orders, products_n_prices
    - add peak or non-peak behind each orders

    | Period   | Revenue | Hours | Revenue/Hour |
    | -------- | ------- | ----- | ------------ |   
    | Peak     | 12000   | 20    | 600          |
    | Non-peak | 8000    | 60    | 133          |
*/

WITH orders_rev AS(
    SELECT
        o.order_id,
        o.ordered_at,
        (o.quantity * pp.price) AS bill
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
), 
orders_labeled AS (
    SELECT 
        odr.order_id,
        odr.bill,
        CASE 
            WHEN peak_id IS NULL THEN 'non-peak'
            ELSE 'peak'
        END AS period
    FROM orders_rev odr
    JOIN date_dim dd
        ON odr.ordered_at::Date = dd.cal_date
    LEFT JOIN peak_hour_dim phd
        ON phd.day_type = dd.day_type AND phd.hr = EXTRACT(HOUR FROM odr.ordered_at)
), 
total_hrs AS (
     SELECT
        orl.period,
        SUM(orl.bill) AS revenue,
        CASE 
            WHEN period = 'peak' THEN 10
            ELSE 7*12-10
        END AS hr
    FROM orders_labeled orl
    GROUP BY period
)
SELECT
    total_hrs.period,
    total_hrs.revenue,
    total_hrs.hr,
    ROUND(revenue*1.0/hr, 2)  AS rev_per_hr
FROM total_hrs;

-- Q2-1: Which products generate the highest revenue?
/*
    - products_n_prices, orders
    1. sum the revenue of all products accross Feb
    2. order by
    - product_id, product name, revenue it contributed
*/

SELECT 
    pp.product_id,
    pp.name,
    SUM(o.quantity * pp.price) AS rev_in_feb
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id
GROUP BY pp.product_id, pp.name
ORDER BY rev_in_feb DESC;

-- after plotting: top 14 contribute to majority of the revenue.
SELECT 
    pp.product_id,
    pp.name,
    SUM(o.quantity * pp.price) AS rev_in_feb
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id
GROUP BY pp.product_id, pp.name
ORDER BY rev_in_feb DESC
LIMIT 14; -- add limit 14 to see only the top contributors.

-- Q3: Which product categories generate the highest revenue?
/*
    - what categories?
        - hot vs iced
        - coffee vs non-coffee
        - food vs drinks
        - drink flavor regardless of hot or cold or size
*/
-- hot vs iced?
WITH revenue_per_product AS (
    SELECT
        pp.product_id,
        pp.name,
        SUM(o.quantity *pp.price) AS rev
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    WHERE pp.drink_id IS NOT NULL
    GROUP BY 
        pp.product_id,
        pp.name
),
labeled_drinks AS (
    SELECT 
        rpp.product_id,
        rpp.name,
        rpp.rev,
        CASE
            WHEN rpp.name LIKE 'Iced%'
                OR rpp.name LIKE 'Cold%'
                OR rpp.name LIKE '%Lemonade%'
            THEN 'Cold'
            ELSE 'Hot' 
        END AS category
    FROM revenue_per_product rpp
)
SELECT 
    ld.category,
    SUM(ld.rev) AS category_rev
FROM labeled_drinks ld
GROUP BY ld.category
ORDER BY category_rev DESC;

-- coffee vs non-coffee?
WITH labeled_drinks AS (
    SELECT 
        pp.product_id,
        pp.price,
        CASE
            WHEN dt.caffeine_level = 'Caffeinated'THEN 'Coffee'
            ELSE 'Non-Coffee' 
        END AS category
    FROM products_n_prices pp
    JOIN drink_types dt ON pp.drink_id = dt.drink_id
    WHERE pp.drink_id IS NOT NULL
)
SELECT
    ld.category,
    SUM(o.quantity * ld.price) AS category_rev
FROM orders o
JOIN labeled_drinks ld ON o.product_id = ld.product_id
GROUP BY ld.category 
ORDER BY category_rev DESC;

-- drink flavor regardless of hot or cold or size
WITH revenue_per_drink_type AS (
    SELECT
        pp.drink_id,
        SUM(o.quantity *pp.price) AS rev
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    WHERE pp.drink_id IS NOT NULL
    GROUP BY 
        pp.drink_id
    ORDER BY pp.drink_id
)
SELECT
    dt.drink_id,
    dt.name, 
    rpdt.rev
FROM revenue_per_drink_type rpdt
JOIN drink_types dt ON rpdt.drink_id = dt.drink_id
ORDER BY rpdt.rev DESC;

-- food vs drinks?
WITH revenue_per_product AS (
    SELECT
        -- pp.product_id,
        CASE
            WHEN pp.drink_id IS NOT NULL THEN 'drink'
            ELSE 'food'
        END AS category,
        SUM (o.quantity * pp.price) AS rev
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    -- GROUP BY pp.product_id
    GROUP BY category
)
SELECT
    CASE
        WHEN pp.drink_id IS NOT NULL THEN 'drink'
        ELSE 'food'
    END AS category
FROM orders o
JOIN revenue_per_product rpp ON o.product_id = rpp.product_id

-- Q4: Which products sell often but generate low revenue?
/*
    - what categories?
        - hot vs iced
        - coffee vs non-coffee
        - food vs drinks
        - drink flavor regardless of hot or cold or size
*/
