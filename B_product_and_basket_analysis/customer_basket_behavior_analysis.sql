/*
1. customer's basket behavior analysis

Customer Basket Behavior Analysis — Core Questions
1. What is the average basket size? (average items per order)
2. Are customers mostly placing single-item or multi-item orders? (ordering complexity / upsell opportunity)
3. How does basket size vary by time period? (morning vs afternoon vs evening)
4. How does basket behavior vary by channel? (delivery vs in-store)
5. Do a relatively small number of large baskets generate a disproportionately large share of revenue? (business value of large orders)

2*
| Basket Type | % of Orders |
| ----------- | ----------- |
| Single-item | 72%         |
| Multi-item  | 28%         |

*/

-- Q1: What is the average basket size? (feb)
SELECT
    ROUND(
        SUM(o.quantity)*1.0/COUNT(DISTINCT o.order_id),
        2
    ) AS avg_basket_size
FROM orders o

-- Q2: Are customers mostly placing single-item or multi-item orders?
/*
    | Basket Type | % of Orders |
    | ----------- | ----------- |
    | Single-item | 72%         |
    | Multi-item  | 28%         |
*/
WITH basket_types AS (
    SELECT
        o.order_id,
        CASE
            WHEN SUM(o.quantity) = 1 THEN 'Single-item'
            WHEN SUM(o.quantity) > 1 THEN 'Multi-item'
            ELSE 'error'
        END AS basket_type
    FROM orders o
    GROUP BY o.order_id
)
SELECT
    bt.basket_type,
    ROUND(
        COUNT(*)*100.0/ (SELECT COUNT(*) FROM basket_types),
        2
    ) AS p_of_orders
FROM basket_types bt
GROUP BY bt.basket_type


-- Q3: How does basket size vary by time period? (morning vs afternoon vs evening)
/*

    - separate hour and weekday and weekday
    - x-axis: weekday at 7,...weekend at 18
    - y-axis: avg basket size
    - orders
        1. MIN(o.ordered_at)
*/
WITH orders_2 AS (
    SELECT
        order_id,
        MIN(ordered_at) AS ordered_at,
        SUM(quantity) AS item_count
    FROM orders
    GROUP BY order_id
), avg_basket_sizes AS (
    SELECT
        EXTRACT(HOUR FROM o2.ordered_at) AS hr, 
        CASE 
            WHEN EXTRACT(DOW FROM o2.ordered_at) IN (0,6) THEN 'Weekend' ELSE 'Weekday' 
        END AS wk_type,
        ROUND(
            SUM(o2.item_count)*1.0/COUNT(*),
            2
        ) AS avg_basket_size
    FROM orders_2 o2
    GROUP BY 
        hr,
        wk_type
    ORDER BY 
        hr,
        wk_type
)
SELECT -- make into pivit table
    hr,
    MAX(CASE WHEN wk_type = 'Weekday' THEN avg_basket_size END) AS Weekday,
    MAX(CASE WHEN wk_type = 'Weekend' THEN avg_basket_size END) AS Weekend
FROM 
    avg_basket_sizes
GROUP BY 
    hr
ORDER BY 
    hr;

-- Q4: How does basket behavior vary by channel? (delivery vs in-store)
/*
    - x-axis: channels
    - y-axis: avg basket size

*/
WITH orders_2 AS (
    SELECT
        order_id,
        MIN(ordered_at) AS ordered_at,
        SUM(quantity) AS item_count,
        MIN(channel) AS channel
    FROM orders
    GROUP BY order_id
)
SELECT
    channel,
    ROUND(
        SUM(item_count)*1.0/COUNT(*),
        2
    )AS avg_basket_size
FROM orders_2
GROUP BY channel;

-- Q4-2: How does basket behavior vary by channel + time period? (weekday)
/*
    - x-axis: channels
    - y-axis: avg basket size

*/
WITH orders_2 AS (
    SELECT
        order_id,
        MIN(ordered_at) AS ordered_at,
        SUM(quantity) AS item_count,
        MIN(channel) AS Channel
    FROM orders
    GROUP BY order_id
), avg_basket_sizes AS (
    SELECT
        channel,
        EXTRACT(HOUR FROM o2.ordered_at) AS hr,
        ROUND(
            SUM(o2.item_count)*1.0/COUNT(*),
            2
        ) AS wk_day_avg_basket_size
    FROM orders_2 o2
    WHERE EXTRACT(DOW FROM o2.ordered_at) IN (1, 2, 3, 4, 5)
    GROUP BY 
        channel,
        hr
    ORDER BY 
        channel,
        hr
)
SELECT
    hr,
    MAX(CASE WHEN channel = 'in-person' THEN wk_day_avg_basket_size END) AS in_person,
    MAX(CASE WHEN channel = 'store-app' THEN wk_day_avg_basket_size END) AS store_app,
    MAX(CASE WHEN channel = 'uber' THEN wk_day_avg_basket_size END) AS uber,
    MAX(CASE WHEN channel = 'doordash' THEN wk_day_avg_basket_size END) AS doordash
FROM avg_basket_sizes
GROUP BY hr
ORDER BY hr;

-- Q4-3: How does basket behavior vary by channel + time period? (weekend)
/*
    - x-axis: channels
    - y-axis: avg basket size

*/
WITH orders_2 AS (
    SELECT
        order_id,
        MIN(ordered_at) AS ordered_at,
        SUM(quantity) AS item_count,
        MIN(channel) AS Channel
    FROM orders
    GROUP BY order_id
), avg_basket_sizes AS (
    SELECT
        channel,
        EXTRACT(HOUR FROM o2.ordered_at) AS hr,
        ROUND(
            SUM(o2.item_count)*1.0/COUNT(*),
            2
        ) AS wk_end_avg_basket_size
    FROM orders_2 o2
    WHERE EXTRACT(DOW FROM o2.ordered_at) IN (0,6)
    GROUP BY 
        channel,
        hr
    ORDER BY 
        channel,
        hr
)
SELECT
    hr,
    MAX(CASE WHEN channel = 'in-person' THEN wk_end_avg_basket_size END) AS in_person,
    MAX(CASE WHEN channel = 'store-app' THEN wk_end_avg_basket_size END) AS store_app,
    MAX(CASE WHEN channel = 'uber' THEN wk_end_avg_basket_size END) AS uber,
    MAX(CASE WHEN channel = 'doordash' THEN wk_end_avg_basket_size END) AS doordash
FROM avg_basket_sizes
GROUP BY hr
ORDER BY hr;

-- Q5: Do a relatively small number of large baskets generate a disproportionately large share of revenue? (business value of large orders)
/*

    - separate hour and weekday and weekday
    - x-axis: weekday at 7,...weekend at 18
    - y-axis: avg basket size
    - orders
        1. MIN(o.ordered_at)
*/