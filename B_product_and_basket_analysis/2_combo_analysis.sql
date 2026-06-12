/*
Market basket analysis/Product Affinity Analysis/product association/combo analysis (Classic MBA.)

Focus: “Which exact products are frequently purchased together?”



Frequently bought together items
Common pairings (e.g., coffee + pastry)


What are the most common product combinations?
Which combos occur more often than expected?
What products should be bundled together?

| Product A | Product B | Frequency |
| --------- | --------- | --------- |
| Coffee    | Croissant | 1,245     |
| Latte     | Muffin    | 875       |
| Tea       | Scone     | 632       |

| Antecedent | Consequent | Support | Confidence | Lift |
| ---------- | ---------- | ------- | ---------- | ---- |
| Coffee     | Croissant  | 8%      | 35%        | 1.8  |


*/

-- Q: Which exact products are frequently purchased together?
/*
- include only orders that > 1 items purchased.

*/

SELECT
    order_id,

FROM orders
GROUP BY order_id
HAVING COUNT(product_id) > 1 -- does 2 latte count as a rule?


-- step 1: frequency of all products purchased to determine who is the Antecedent (& consequent) worth analyzing on.
/*
    - counting the product types in orders => 2 lattes in 1 orders is counted as frequency = 1.
    - brewed coffee small and brewed coffee medium => treated into the same product (type).
    Conclusion: elbow at spinach & egg white wrap. combo analysis on all 11 products prior to that.
*/
SELECT
    pp.name,
    COUNT(DISTINCT o.order_id) AS appeared_freq
FROM orders o
JOIN products_n_prices pp ON o.product_id = pp.product_id
GROUP BY pp.name
ORDER BY appeared_freq DESC
LIMIT 11;

-- step 2: orginal orders table filtered (top 11 in frq, only count(product_id) > 1, product A and B only from top 11)
-- step 3: self join the list of order_ids
-- step 4: display: product_a, product_b, and pair_count
WITH important_products AS (
    SELECT
        pp.name,
        COUNT(DISTINCT o.order_id) AS appeared_freq
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    GROUP BY pp.name
    ORDER BY appeared_freq DESC
    LIMIT 11
),
filtered_order_ids AS (
    SELECT
        o.order_id,
        pp.name AS product_name
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    WHERE pp.name IN (
        SELECT ip.name
        FROM important_products ip
    )
),
multi_item_orders AS (
    SELECT
        order_id
    FROM orders
    GROUP BY order_id
    HAVING COUNT(product_id) > 1
),
base AS (
    SELECT f.*
    FROM filtered_order_ids f
    JOIN multi_item_orders m ON f.order_id = m.order_id
),
pairs AS (
    SELECT
        a.order_id,
        a.product_name AS product_a,
        b.product_name AS product_b
    FROM base a
    JOIN base b
        ON a.order_id = b.order_id
        AND a.product_name < b.product_name
)
SELECT
    product_a,
    product_b,
    COUNT(*) AS pair_count
FROM pairs
GROUP BY 1,2
ORDER BY pair_count DESC;


-- support, confidence, lift
WITH important_products AS (
    SELECT
        pp.name,
        COUNT(DISTINCT o.order_id) AS appeared_freq
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    GROUP BY pp.name
    ORDER BY appeared_freq DESC
    LIMIT 11
),
filtered_order_ids AS (
    SELECT
        o.order_id,
        pp.name AS product_name
    FROM orders o
    JOIN products_n_prices pp ON o.product_id = pp.product_id
    WHERE pp.name IN (
        SELECT ip.name
        FROM important_products ip
    )
),
multi_item_orders AS (
    SELECT
        order_id
    FROM orders
    GROUP BY order_id
    HAVING COUNT(product_id) > 1
),
base AS (
    SELECT f.*
    FROM filtered_order_ids f
    JOIN multi_item_orders m ON f.order_id = m.order_id
),
pairs AS (
    SELECT
        a.order_id,
        a.product_name AS product_a,
        b.product_name AS product_b
    FROM base a
    JOIN base b
        ON a.order_id = b.order_id
        AND a.product_name < b.product_name
),
pairs_frequency AS (
    SELECT
        product_a,
        product_b,
        COUNT(*) AS pair_count
    FROM pairs
    GROUP BY 1,2
    ORDER BY pair_count DESC
    LIMIT 10
), 
support_n_confidence AS (
    SELECT
        pf.product_a AS antecedent,
        pf.product_b AS consequent,
        ROUND(
            pf.pair_count *100.0/(SELECT COUNT(DISTINCT order_id) FROM orders),
            2
        ) AS support_p,
        ROUND (
            pf.pair_count *100.0/(
                SELECT COUNT(DISTINCT o.order_id) 
                FROM orders o
                JOIN products_n_prices pp ON o.product_id = pp.product_id
                WHERE pp.name = pf.product_a
            ), 
            2
        ) AS confidence_p
    FROM pairs_frequency pf
)
SELECT
    *,
    ROUND(confidence_p/support_p, 2) AS lift
FROM support_n_confidence;
