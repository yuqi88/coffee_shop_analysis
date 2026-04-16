/*
    Q2-1: Which peak contributes the most revenue?
    Q2-2: Is it drinks or food that drives the revenue in each peak? What food? What drink?
    Q2-3: Delivery more or in-person during each peak vs non-peak?
    How do different peak periods compare in terms of revenue, volume, and customer behavior, 
    and what operational or growth opportunities does each period present?

    Core question: Which peak period contributes the most revenue?
    Supporting questions:
        - Which peak has the most orders?
        - Which peak has the highest total quantity (workload)?
        - Which peak has the highest average order value (AOV)?
        - Which peak is most delivery-heavy vs in-person?
        - Which peak has the most food add-ons (upsell potential)?

    1. Define peaks (you already did)
    2. Compare across:
        - revenue
        - orders
        - quantity
        - AOV 
    3. Identify differences
    4. Recommend actions



    Insights for:
    - Optinize operations: staffing, procedures, inventory, from order to shipment speed.
    - Goal: Drive higher revenue (customer satisfication, workplace satisfiction, smooth business operation.)

*/

/*
    Weekdays show peaks at 8–9 AM, 11 AM–12 PM, and 4–5 PM  
    Weekends shift later to 10–11 AM and 2–3 PM  
*/
SELECT *
FROM orders
ORDER BY order_id
LIMIT 100;

/*
    How to I get revenue?
    Ans:
    Revenue of a order
        = in the same order, product_id * quantity 
        =  ..., product_id -> price in products_n_prices table *quantity *quantity


*/
--let's just get the revenue for the top 10 orders
SELECT 
    order_id,
    SUM(orders.quantity * products_n_prices.price) AS revenue_per_order
FROM orders
JOIN products_n_prices ON orders.product_id = products_n_prices.product_id
GROUP BY order_id
ORDER BY order_id
LIMIT 100;

-- create a date_dim table
CREATE TABLE date_dim (
    cal_date DATE PRIMARY KEY,
    day_name TEXT, -- Monday, Tuesday....
    day_type TEXT, -- weekday or weekend
    is_valentine_weekend BOOLEAN
);


INSERT INTO date_dim (
    cal_date
) SELECT generate_series (
    '2026-02-01'::date,
    '2026-02-28'::date,
    '1 day'
);

SELECT * FROM date_dim;

-- step 3 on ChatGPT
UPDATE date_dim
SET 
    day_name = TO_CHAR(cal_date, 'Day'),
    day_type = 
        CASE 
            WHEN EXTRACT(DOW FROM cal_date) IN (0,6) THEN 'Weekend'
            ELSE 'Weekday'
        END,
    is_valentine_weekend = cal_date IN ('2026-02-14', '2026-02-15');



-- Which peak period contributes the most revenue?
/*
    1. get peak
        - weekday/weekend + hours
    2. get revenue

*/
/*
    Weekdays show peaks at 8–9 AM, 11 AM–12 PM, and 4–5 PM  
    Weekends shift later to 10–11 AM and 2–3 PM  
*/
-- avg revenue per peak
SELECT 
    day_type,
    EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
    ROUND(SUM(orders.quantity * products_n_prices.price)*1.0/ COUNT(DISTINCT ordered_at::DATE), 2) AS avg_revenue_per_peak
FROM orders
JOIN products_n_prices 
    ON orders.product_id = products_n_prices.product_id
JOIN date_dim 
    ON orders.ordered_at::DATE = date_dim.cal_date 
WHERE
    (day_type = 'Weekday' AND EXTRACT(HOUR FROM ordered_at) IN (8,9,11,12,16,17)) OR
    (day_type = 'Weekend' AND EXTRACT(HOUR FROM ordered_at) IN (10,11,14,15)) 
GROUP BY 
    day_type, 
    order_at_hour
ORDER BY avg_revenue_per_peak DESC;

-- -- try optimize with the pkh table
-- SELECT 
--     pkh.day_type,
--     EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
--     ROUND(SUM(o.quantity * pp.price)*1.0/ COUNT(DISTINCT o.ordered_at::DATE), 2) AS avg_revenue_per_peak
-- FROM orders o
-- JOIN products_n_prices pp
--     ON o.product_id = pp.product_id
-- JOIN date_dim dd
--     ON o.ordered_at::DATE = dd.cal_date -- provides: Monday, tuesday, wednesday.... + weekend/weekday
-- JOIN peak_hour_dim pkh
--     ON  dd.day_type= pkh.day_type AND EXTRACT(HOUR FROM o.ordered_at) = pkh.hr -- provides: weekend/weekday + hours: 8 am....
-- GROUP BY 
--     pkh.day_type, 
--     order_at_hour
-- ORDER BY avg_revenue_per_peak DESC;
/*
    wkd 10-11 > wkd 15 > wky 8-9 > wkd 14 > ....
*/


-- Q2s1: Which peak has the most orders?
CREATE TABLE peak_hour_dim (
    peak_id SERIAL PRIMARY KEY,
    day_type TEXT, -- weekend/weekday
    hr INT,
    peak_label TEXT,
    UNIQUE (day_type, hr)
);

INSERT INTO peak_hour_dim (day_type, hr, peak_label) 
VALUES 
    -- Weekday peaks
    ('Weekday', 8, 'morning'),
    ('Weekday', 9, 'morning'),
    ('Weekday', 11, 'lunch'),
    ('Weekday', 12, 'lunch'),
    ('Weekday', 16, 'late_afternoon'),
    ('Weekday', 17, 'late_afternoon'),
    -- Weekend peaks
    ('Weekend', 10, 'late_morning'),
    ('Weekend', 11, 'late_morning'),
    ('Weekend', 14, 'afternoon'),
    ('Weekend', 15, 'afternoon');

SELECT * FROM peak_hour_dim;

/*
    Which peak has the most orders?
    - need peak info
    - need order info -> count order_id
    - how do i demonstrated it?
*/

SELECT *
FROM peak_hour_dim pkh
JOIN orders o
    ON pkh.hr = o.ordered_at::HOUR --wrong
;

SELECT * FROM date_dim;

SELECT 
    dd.day_type,
    EXTRACT(HOUR FROM o.ordered_at) AS order_at_hour,
    ROUND(COUNT(DISTINCT o.order_id)*1.0/ COUNT(DISTINCT o.ordered_at::DATE), 2) AS avg_order_count_per_peak
FROM orders o
JOIN date_dim dd
    ON o.ordered_at::DATE = dd.cal_date
WHERE
    -- get only from the peak hours
    (dd.day_type = 'Weekday' AND EXTRACT(HOUR FROM ordered_at) IN (8,9,11,12,16,17)) OR
    (dd.day_type = 'Weekend' AND EXTRACT(HOUR FROM ordered_at) IN (10,11,14,15)) 
GROUP BY 
    day_type, 
    order_at_hour
ORDER BY avg_order_count_per_peak DESC
;

-- -- optimized version
-- SELECT 
--     dd.day_type,
--     EXTRACT(HOUR FROM o.ordered_at) AS order_at_hour,
--     ROUND(COUNT(DISTINCT o.order_id)*1.0/ COUNT(DISTINCT o.ordered_at::DATE), 2) AS avg_order_count_per_peak
-- FROM orders o
-- JOIN date_dim dd
--     ON o.ordered_at::DATE = dd.cal_date
-- JOIN peak_hour_dim pk
--     ON EXTRACT(HOUR FROM o.ordered_at) = pk.hr AND dd.day_type = pk.day_type
-- GROUP BY 
--     dd.day_type, 
--     order_at_hour
-- ;

-- Most order: wkd 11 > wkd 10 > wkd 15 > wky 8 > wky 9 > wky 14 > ...


/*
    Q2s2: Which peak has the highest total quantity (workload)?
    - drink quantities - count cup of drinks
    - which peak: day_type(weekend/weekday) from date_dim or peak_hour_dim + the hour(7am, 8am, etc) from orders or peak_hour_dim
    - over a period of time (february), with different counts of weekdays vs weekends -> do avg for the count.
*/
SELECT 
    phd.day_type,
    phd.hr,
    ROUND(SUM(o.quantity)*1.0/COUNT(DISTINCT o.ordered_at::DATE), 2) AS avg_items_per_peak
FROM orders o 
JOIN date_dim dd
    ON o.ordered_at::Date = dd.cal_date
JOIN peak_hour_dim phd
    ON phd.day_type = dd.day_type AND phd.hr = EXTRACT(HOUR FROM o.ordered_at)
GROUP BY 
    phd.day_type,
    phd.hr
ORDER BY avg_items_per_peak DESC;
-- wkd 11 > wkd 10 > wkd 15 > wky 8 > wky 9 > wkd 14 > ...

/*
    Q2s3: Which peak has the highest average order value (AOV)?
    - AOV = total revenue/ number of orders.
    - o.price, count(DISTINCT o.order_id) -> orders
    - peak: phd.day_type + phd.hours

*/
SELECT TRIM(TO_CHAR('2026-02-01'::Date,'Day'));

SELECT 
    phd.day_type,
    phd.hr,
    ROUND(SUM(o.quantity * pp.price)*1.0/COUNT(DISTINCT o.order_id), 2) AS aov
FROM orders o 
JOIN date_dim dd
    ON o.ordered_at::Date = dd.cal_date
JOIN peak_hour_dim phd
    ON phd.day_type = dd.day_type AND phd.hr = EXTRACT(HOUR FROM o.ordered_at)
JOIN products_n_prices pp
    ON o.product_id = pp.product_id
GROUP BY 
    phd.day_type,
    phd.hr
ORDER BY aov DESC;
-- wky 11 > wky 8 > wky 15 >.. all pretty close actually. Max : min=  25.60 : 23.65

/*
    Q2s4: Which peak is most delivery-heavy vs in-person?

*/
