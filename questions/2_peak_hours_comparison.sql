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
    - count delivery & count in-person -> orders table
        - values under channel: in-person, store-app, uber, doordash.
            - non-delivery: in-person + store-app
            - delivery: uber + doordash
        - count the channel from distinct order_ids -> do avg since # of wkd and wky is different.
    - peak: phd.day_type + phd.hours

    Q2s4-1: “Which peak has the most delivery orders vs the most in-person orders?” -> count
    Q2s4-2: “Which peak is mostly dominated by delivery vs in-person?” -> ratio

    They answer different business questions:
    -> Ops staffing → volume
    -> Channel strategy → ratio

*/
SELECT *
FROM orders
LIMIT 10;

-- in-person count
WITH no_dups_orders AS ( --remove all duplicated order_id rows, and then cte for orders.channel
    SELECT 
        DISTINCT order_id, 
        ordered_at,
        channel
    FROM orders
) SELECT 
    phd.day_type,
    phd.hr,
    COUNT(ndo.channel) AS inperson_count_per_peak
FROM no_dups_orders ndo
JOIN date_dim dd
    ON ndo.ordered_at::DATE = dd.cal_date
JOIN peak_hour_dim phd
    ON EXTRACT(HOUR FROM ndo.ordered_at) = phd.hr AND dd.day_type = phd.day_type
WHERE ndo.channel = 'in-person'
GROUP BY
    phd.day_type,
    phd.hr
;

-- group by all types of channels: in-person vs uber vs doordash (use case, end  -> delivery)
WITH no_dups_orders AS ( 
    SELECT 
        DISTINCT order_id, 
        ordered_at,
        channel,
        CASE
            WHEN channel IN ('doordash', 'uber') THEN 'delivery'
            ELSE 'non-delivery'
        END AS channels_2
    FROM orders
) SELECT 
    phd.day_type,
    phd.hr,
    ndo.channels_2,
    ROUND(COUNT(ndo.channels_2)*1.0/COUNT(DISTINCT ndo.ordered_at::DATE), 2) AS channels_count_per_peak
FROM no_dups_orders ndo
JOIN date_dim dd
    ON ndo.ordered_at::DATE = dd.cal_date
JOIN peak_hour_dim phd
    ON EXTRACT(HOUR FROM ndo.ordered_at) = phd.hr AND dd.day_type = phd.day_type
GROUP BY
    ndo.channels_2,
    phd.day_type,
    phd.hr
ORDER BY 
    channels_2, 
    channels_count_per_peak DESC
;
-- number of in-peson & delivery both hit the highest during the weekend. 
-- With delivery peaking at 11 am, and non-delivery(in-person & store-app) at 10 am.

-- learning 1: do checking for data miss matches: in the same order_id, not the same ordered_at or the same channel.
-- learning 2: instead of using distinct order_id, take min(ordered_at), min(channel)


-- Q2s4-2
WITH no_dups_orders AS ( 
    SELECT 
        order_id, 
        MIN(ordered_at) AS ordered_at,
        CASE
            WHEN MIN(channel) IN ('doordash', 'uber') THEN 'delivery'
            ELSE 'non-delivery'
        END AS channels_2
    FROM orders
    GROUP BY order_id
) 
SELECT 
    phd.day_type,
    phd.hr,
    ROUND(
        SUM(CASE WHEN ndo.channels_2 = 'delivery' THEN 1 ELSE 0 END) * 1.0 
        / COUNT(*), 
    2) * 100 || '%' AS delivery_ratio_at_peaks
FROM no_dups_orders ndo
JOIN date_dim dd
    ON ndo.ordered_at::DATE = dd.cal_date
JOIN peak_hour_dim phd
    ON EXTRACT(HOUR FROM ndo.ordered_at) = phd.hr AND dd.day_type = phd.day_type
GROUP BY
    phd.day_type,
    phd.hr
ORDER BY 
    phd.day_type, 
    phd.hr 
;
-- heavy during lunch


/*
    Q2s5: Which peak has the most food add-ons (upsell potential)?
    - looking for ratio since volume of orders in each peak is different.
        - Sum(orders of <food + drink>)/Count(#orders)
    - assuming we are looking for food adding on the drink orders, not the otherway around. Cuz ppl usually get coffee at a coffee shop.

    Get orders during peak -> order table, peak table
    cross product_id  -> products_n_prices table has food or drink info

    

*/
SELECT 
    dd.day_type,
    EXTRACT(HOUR FROM o.ordered_at) AS hr,
    -- if in the same order_id && there exist food_id & drink_id, then count++
    ROUND(
        SUM(CASE 
                WHEN pp.drink_id IS NOT NULL and pp.food_id IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 1.0, -- divid by peak (cant group by order_id + peak)
        2
    ) AS upsell_ratio_at_peaks
FROM orders o
JOIN date_dim dd
    ON o.ordered_at::DATE = dd.cal_date
JOIN products_n_prices pp
    ON o.product_id = pp.product_id
WHERE
    -- get only from the peak hours
    (dd.day_type = 'Weekday' AND EXTRACT(HOUR FROM ordered_at) IN (8,9,11,12,16,17)) OR
    (dd.day_type = 'Weekend' AND EXTRACT(HOUR FROM ordered_at) IN (10,11,14,15)) 
GROUP BY o.order_id
;

SELECT 
    CASE
        WHEN '123' <>'' and 'abc' <> '' THEN 1
        ELSE 0
    END AS col1;


WITH labelled_orders AS (
    SELECT 
        o.order_id,
        BOOL_OR(
            CASE
                WHEN pp.drink_id IS NOT NULL THEN TRUE
                ELSE FALSE
            END
        ) AS has_drink,
        BOOL_OR(
            CASE
                WHEN pp.food_id IS NOT NULL THEN TRUE
                ELSE FALSE
            END
        ) AS has_food
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    GROUP BY o.order_id
    LIMIT 50
    -- HAVING
    --     num_nulls(p.drink_id , p.food_id) = 0 -- has both drink & food
) SELECT
    phd.day_type,
    phd.hr,
    ROUND(
        COUNT(DISTINCT o.order_id) FILTER (WHERE lo.has_drink AND lo.has_food) *1.0 
        /
        COUNT(DISTINCT o.order_id) FILTER (WHERE lo.has_drink),
        2
    ) AS upsell_ratio_at_peaks
    
    -- ratio: COUNT(combo_order) *1.0/ COUNT(DISTINCT order_id)AS upsell_ratio_at_peaks
FROM orders o
JOIN labelled_orders lo
    ON o.order_id = lo.order_id
JOIN date_dim dd
    ON o.ordered_at::DATE = dd.cal_date
JOIN peak_hour_dim phd
    ON EXTRACT(HOUR FROM o.ordered_at) = phd.hr AND dd.day_type = phd.day_type
GROUP BY
    phd.day_type,
    phd.hr
;
-- weekend 2 pm has the most combo orders, lunch time on the weekdays has the lest.