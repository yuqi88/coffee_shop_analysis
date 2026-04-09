/*
    Q1: I want to find the peak business hours.
    - extract the hours from the ordered_at.
    - agregate the total/avg numbers of order on the hours accross the entire February data.
    - sanity check for hidden different behaviours: e.g. (1) weekends vs weekdays (2) valentine's
    - see if separate peaks are needed, or just one (the same peaks)
*/

-- SELECT EXTRACT(HOUR FROM ordered_at) AS ordered_at_hour
-- FROM orders
-- LIMIT 10;

SELECT 
    EXTRACT(HOUR FROM ordered_at) AS ordered_at_hour,
    count(DISTINCT order_id) AS feb_total_order_count_per_hour
FROM orders
GROUP BY 
    ordered_at_hour;

-- SELECT EXTRACT(DOW FROM TIMESTAMP '2026-04-08') AS ordered_at_dow
-- ;

-- SELECT 
--     ordered_at,
--     EXTRACT(DOW FROM ordered_at) AS ordered_at_dow,
--     TO_CHAR(ordered_at, 'Day') AS ordered_at_dow_txt
-- FROM orders
-- LIMIT 10;
-- -- WHERE EXTRACT(DOW FROM ordered_at) IN (6,0) -- flitering in only weekend

-- group by week vs weekend
SELECT 
    CASE
        WHEN EXTRACT(DOW FROM ordered_at) IN (6,0) THEN 'weekend'
        ELSE 'weekday'
    END AS day_type,
    EXTRACT(HOUR FROM ordered_at) AS order_at_hour,
    COUNT(DISTINCT order_id) AS feb_total_orders
FROM orders
GROUP BY
    day_type,
    order_at_hour
ORDER BY 
    day_type, 
    feb_total_orders DESC
;
-- Weekday vs Weekend have different customer behaviors.
-- weekday peaks: 8-9, 11-12, 16-17. Include both end.
-- weekend peaks: 10-11, 14-15. Include both end.

/* 
-- #1 analyze week
SELECT 
    EXTRACT(HOUR FROM ordered_at) AS ordered_at_hour,
    COUNT(DISTINCT order_id) AS feb_order_count_per_hour_weekday
FROM orders
WHERE ordered_at in weekdays?
GROUP BY
    ordered_at_hour;

-- #2 analyze weekend
-- #3 see if they have the same pattern or not

    don't have to do it separately. Using case expression to categorize is not the cleanest for readablitity, 
    usually it is done by adding a col (day_type: weekend or weekday) or creating another table including day_type. 
    But this is a ad hoc analysis, so it's okay.
*/


-- weekend peak of valentine's vs normal ones: are there differents? 2/14 is a Saturday.

-- SELECT EXTRACT(DAY FROM DATE '2026-04-08') as mydate;


SELECT
    CASE
        WHEN EXTRACT(DAY FROM ordered_at) IN (14, 15) THEN 'valentine_weekend'
        ELSE 'normal_weekends'
    END AS weekend_type, 
    EXTRACT(HOUR FROM ordered_at) AS ordered_at_hour,
    ROUND(COUNT(DISTINCT order_id) *1.0/ COUNT(DISTINCT ordered_at::DATE), 2) AS avg_orders_per_wkend_day
FROM orders
WHERE EXTRACT(DOW FROM ordered_at) IN (6,0)
GROUP BY 
    weekend_type, 
    ordered_at_hour
ORDER BY
    weekend_type, 
    avg_orders_per_wkend_day DESC
;
-- peak for both types of weekend are consistent: 10-11, 14-15. Include both end.
-- however, valentine week does have more customers than other weekends on avgerage.