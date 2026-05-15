
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
    o.ordered_at_hour;

-- Q3-1 : Are weekends different from weekdays? (order per hour)
--TODO: make this into a pivot table
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
-- 2*: When are the peak sales periods (revenue per hour)?
-- Q4: Other periods of time to compare: valentine's week/weekday/weekend
-- Revenue analysis

/*
Time-based analysis (revenues & sales)
    Q1: When are the peak sales periods (orders per hour)?
    Q2: When are the peak sales periods (AOV per hour)?
        *: When are the peak sales periods (revenue per hour)?
    Q3: Are weekends different from weekdays?
        - order per hour
        - revenue per hour
        - AOV: average order value = total revenue /total transactions
    Q4: Other periods of time to compare: valentine's week/weekday/weekend

    B1: opteration hours change, staffing + break schedule, schedule prep time, cut down customer wait time.
    B2: Busy does not always mean profitable. Which periods need revenue improvement? (marketing focus + staffing priority)
    B3:  - 
    B4:  - 
*/

/*
    Revenue analysis
    Q0: Total revenue
    Q1: Revenue by time
        - Total revenue by weeks/months
        - Peak vs non-peak sales(revenue from selling; there are non-selling revenues. E.g. acquistion or inventment)
    Q2: Revenue by product
        - Which products generate the highest revenue?
    Q3: Revenue by product category
    Q4: Revenue by product and traffic
        - Which products sell often but generate low revenue?
*/

/*

    Channel analysis = (traffic + customer behavor)
Q1: Revenue by channel
    - Do delivery customers spend more?
Q2: Each peak's (time peroid. Morning, noon, ...) channel distribution is?
    - Does in-person traffic dominate mornings?
    - Which channel performs best during peak hours?
*/

/*

Product analysis/Market Basket Analysis
- Which product categories sell the most?

1. customer's basket behavior analysis
    - Average items per order
    - Peak-hour/weekend/morning basket sizes
    - Delivery vs in-person basket behavior
2. Ancors + Add-ons Analysis
3. Add-on Analysis
    - Which drink/drink category lead to add-ons
    - What are the more frequent add-ons
    - Is the ancor and add-ons different during different period or channels?
    - What percentage of coffee orders include food?

    - What are the most common product combinations?
    - Which combos occur more often than expected?
    -What products should be bundled together?
4. Strategic Basket Questions (conclusion from the above 3 quesions)
Should we create combo deals?
Which products should be placed near checkout?
Which items deserve upsell prompts?
Which products increase AOV most?
Which products are “gateway items”?


Strong metrics to include
Attachment rate
Basket size
Items per order
Food add-on ratio
Product pair frequency
Average order value by basket type
*/
