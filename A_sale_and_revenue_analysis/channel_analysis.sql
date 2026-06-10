/*
Channel analysis = (traffic + customer behavor)
    Q1: Revenue by channel
        - Do delivery customers spend more?
    Q2: Each peak's (time peroid. Morning, noon, ...) channel distribution is?
        - Does in-person traffic dominate mornings?
        - Which channel performs best during peak hours?
*/

-- Q1: Do delivery customers spend more?
/*
    - revenue: o.quantity * pp.price
    - channels: o.channel (delievery vs non-delievery)
*/
SELECT
    CASE
        WHEN o.channel IN ('doordash', 'uber') THEN 'delivery'
        ELSE 'non-delivery'
    END AS category,
    SUM(o.quantity * pp.price) AS rev
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id
GROUP BY category


-- Q2-1: Each peak's (time peroid. Morning, noon, ...) channel distribution is?
/*
    - traffic
    - display: col1 = hour; col2 = non-delievery; col3 = delivery
    - orders

    | hour     | non-delivery | delivery |
    | -------- | ------------ | -------- |
    | 7        | 31%          | 69%      |
    | 8        | 88%          | 12%      |
*/
WITH no_dups_orders AS ( 
    SELECT 
        o.order_id,
        MIN(o.ordered_at) AS ordered_at,
        MIN(o.channel) AS channel
    FROM orders o
    GROUP BY o.order_id
),
hour_to_delievery AS (
    SELECT
        EXTRACT(HOUR FROM ordered_at) as hr,
        SUM(CASE WHEN channel IN ('doordash', 'uber') THEN 1 ELSE 0 END) AS delivery,
        COUNT(*) AS order_count
    FROM no_dups_orders
    GROUP by hr
)
SELECT
    hr,
    ROUND(
        delivery*100.0/ order_count,
        2
    ) AS delivery_p,
    ROUND(
        (order_count-delivery)*100.0/ order_count,
        2
    ) AS non_delivery_p
FROM hour_to_delievery
ORDER BY hr;

-- Q2-2: Which channel performs best during peak hours? 
/*
    - traffic
    - uber vs doordash vs in-person vs store-app


    | hour     | uber   | doordash | in-person| store-app |
    | -------- | ------ | -------- | -------- | --------- |
    | 7        | 31%    | 69%      |
    | 8        | 88%    | 12%      |
*/
WITH no_dups_orders AS(
    SELECT
        o.order_id,
        MIN(o.ordered_at) AS ordered_at,
        MIN(channel) AS channel
    FROM orders o
    GROUP BY o.order_id
)
SELECT
    phd.peak_id,
    CONCAT(phd.day_type, ' ', phd.hr) AS peak_name,
    ROUND(
        SUM(CASE WHEN ndo.channel = 'in-person' THEN 1 ELSE 0 END)*100.0/COUNT(*),
        2
    ) AS in_person_p,
        ROUND(
        SUM(CASE WHEN ndo.channel = 'store-app' THEN 1 ELSE 0 END)*100.0/COUNT(*),
        2
    ) AS store_app_p,
        ROUND(
        SUM(CASE WHEN ndo.channel = 'uber' THEN 1 ELSE 0 END)*100.0/COUNT(*),
        2
    ) AS uber_p,
        ROUND(
        SUM(CASE WHEN ndo.channel = 'doordash' THEN 1 ELSE 0 END)*100.0/COUNT(*),
        2
    ) AS doordash_p
FROM no_dups_orders ndo
JOIN date_dim dd
    ON ndo.ordered_at::DATE = dd.cal_date
JOIN peak_hour_dim phd
    ON EXTRACT(HOUR FROM ndo.ordered_at) = phd.hr AND dd.day_type = phd.day_type
GROUP BY
    phd.peak_id,
    phd.day_type,
    phd.hr
ORDER BY 
    phd.peak_id;