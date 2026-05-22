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
