/*
    Revenue analysis
    Q0: Total revenue
    Q1: Revenue by time
        - Total revenue by weeks/months
        - Peak vs non-peak sales(revenue from selling; there are non-selling revenues. E.g. acquistion or inventment)
    Q2: Revenue by product
        - Which products generate the highest revenue?
    Q3: Revenue by product category
        - Which categories sell the most?
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

-- Q1-3: Which products generate the highest revenue?
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
