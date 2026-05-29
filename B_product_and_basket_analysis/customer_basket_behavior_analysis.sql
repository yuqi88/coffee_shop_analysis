/*
1. customer's basket behavior analysis

Customer Basket Behavior Analysis — Core Questions
1. What is the average basket size? (average items per order)
2. Are customers mostly placing single-item or multi-item orders? (ordering complexity / upsell opportunity)
3. How does basket size vary by time period? (morning vs afternoon vs evening)
4. How does basket behavior vary by channel? (delivery vs in-store)
5. Do larger baskets contribute disproportionately to revenue? (business value of large orders)

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


-- Q3: 3. How does basket size vary by time period? (morning vs afternoon vs evening)