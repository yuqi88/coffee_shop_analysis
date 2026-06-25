/*
Which drinks most frequently lead to food add-ons?
Which peak hours have the highest add-on rate?
Do iced drinks lead to more pastries?
What percentage of coffee orders include food?

This is still basket analysis because:
you are analyzing items bought together.

But:it focuses specifically on upselling/cross-selling behavior.


3. Add-on Analysis
    - Which drink/drink category lead to add-ons
    - What are the more frequent add-ons
    - Is the ancor and add-ons different during different period or channels?
    - What percentage of coffee orders include food?

    - What are the most common product combinations?
    - Which combos occur more often than expected?
    -What products should be bundled together?



Step 1: What are customers primarily coming to the cafe for (drinks)?

Step 2: What percentage of drink orders include food?
example:
| Metric              | Value  |
| ------------------- | ------ |
| Drink Orders        | 10,000 |
| Drink + Food Orders | 3,200  |
| Food Attach Rate    | 32%    |

Step 3: Which drinks are most likely to lead to food purchases?
Step 4: When are customers most willing to add food?
Step 5: Does attachment differ by channel? 
Step-bonus: Which food categories are most commonly attached?


*/
-- step 1: What are customers primarily coming to the cafe for (drinks)? Same as combo ananlysis #1. 6481
SELECT
    pp.name,
    COUNT(DISTINCT o.order_id) AS appeared_freq
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id
GROUP BY pp.name
ORDER BY appeared_freq DESC
LIMIT 11;

SELECT COUNT(DISTINCT order_id) FROM orders;

-- step 2: What percentage of drink orders include food? 1036/6221*100% = 16.65%
-- step 2-1: number of orders with drinks:  6221
SELECT
    COUNT(DISTINCT o.order_id) FILTER(WHERE pp.drink_id IS NOT NULL)
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id;

-- step 2-2: number of orders with both drinks and food: 1036
/*
keep the order_id if the order has at least 1 drink and at least 1 food
*/
WITH labelled_orders AS (
    SELECT
        o.order_id,
        MAX(CASE WHEN pp.drink_id IS NOT NULL THEN 1 ELSE 0 END) AS has_drink,
        MAX(CASE WHEN pp.food_id IS NOT NULL THEN 1 ELSE 0 END) AS has_food
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    GROUP BY o.order_id
)
SELECT
    COUNT(order_id)
FROM labelled_orders
WHERE has_drink = 1 AND has_food = 1


-- step 3: Which drinks are most likely to lead to food purchases? (drink's food attachment rate)
/*
    Food Attach Rate by Drink Type x 
    = (orders containing both drink x and at least 1 food item)/(orders containing drink x)
*/
WITH labelled_orders AS (
    SELECT
        o.order_id,
        MAX(CASE WHEN pp.drink_id IS NOT NULL THEN 1 ELSE 0 END) AS has_drink,
        MAX(CASE WHEN pp.food_id IS NOT NULL THEN 1 ELSE 0 END) AS has_food
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    GROUP BY o.order_id
),
orders_w_both AS (
    SELECT
        order_id
    FROM labelled_orders
    WHERE has_drink = 1 AND has_food = 1
),
drink_n_food_in_order_counts AS (
    SELECT
        pp.name,
        COUNT(DISTINCT o.order_id) AS numerator
    FROM orders_w_both owb
    JOIN orders o ON owb.order_id = o.order_id
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    WHERE pp.drink_id IS NOT NULL
    GROUP BY pp.name
),
drink_in_orders_counts AS(
    SELECT
        pp.name,
        COUNT(DISTINCT o.order_id) AS denominator
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    WHERE pp.drink_id IS NOT NULL
    GROUP BY pp.name
)
SELECT
    dnf.name AS drink_category,
    ROUND(
        dnf.numerator *100/d.denominator,
        2
    ) AS food_attchment_rate_p
FROM drink_n_food_in_order_counts dnf
JOIN drink_in_orders_counts d ON dnf.name = d.name
ORDER BY food_attchment_rate_p DESC;

-- step 3-2: add appeared frequency to step 3
/*

*/
WITH labelled_orders AS (
    SELECT
        o.order_id,
        MAX(CASE WHEN pp.drink_id IS NOT NULL THEN 1 ELSE 0 END) AS has_drink,
        MAX(CASE WHEN pp.food_id IS NOT NULL THEN 1 ELSE 0 END) AS has_food
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    GROUP BY o.order_id
),
orders_w_both AS (
    SELECT
        order_id
    FROM labelled_orders
    WHERE has_drink = 1 AND has_food = 1
),
drink_n_food_in_order_counts AS (
    SELECT
        pp.name,
        COUNT(DISTINCT o.order_id) AS numerator
    FROM orders_w_both owb
    JOIN orders o ON owb.order_id = o.order_id
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    WHERE pp.drink_id IS NOT NULL
    GROUP BY pp.name
),
drink_in_orders_counts AS(
    SELECT
        pp.name,
        COUNT(DISTINCT o.order_id) AS denominator
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    WHERE pp.drink_id IS NOT NULL
    GROUP BY pp.name
),
food_attchment AS (
    SELECT
        dnf.name AS drink_category,
        ROUND(
            dnf.numerator *100/d.denominator,
            2
        ) AS food_attchment_rate_p
    FROM drink_n_food_in_order_counts dnf
    JOIN drink_in_orders_counts d ON dnf.name = d.name
),
appeared_frequency AS (
    SELECT
        pp.name,
        COUNT(DISTINCT o.order_id) AS appeared_freq
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    GROUP BY pp.name
)
SELECT
    fa.drink_category,
    fa.food_attchment_rate_p,
    af.appeared_freq,
    fa.food_attchment_rate_p * af.appeared_freq AS multiply
FROM food_attchment fa
JOIN appeared_frequency af ON fa.drink_category = af.name
ORDER BY multiply DESC;
