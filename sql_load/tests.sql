/* Create tables w empty data */
SELECT * FROM drink_types;
SELECT * FROM food_types;
SELECT * FROM ingredients;
SELECT tableowner FROM pg_tables WHERE tablename = 'drink_types';

SELECT * FROM products_n_prices;
SELECT * FROM recipes;
SELECT * FROM orders;

SELECT * FROM package_details;
SELECT * FROM inventory;

/* Start loading data */

SELECT * FROM drink_types;
SELECT * FROM food_types;
SELECT * FROM ingredients;
SELECT * FROM package_details;

SELECT * FROM staging_products;
SELECT * FROM products_n_prices;

SELECT * FROM recipes;
SELECT * FROM inventory;
SELECT * FROM orders; 

-- debugging the order dataset
INSERT INTO orders VALUES ('ORD00087', '2002/1/26 07:02', 35, 4, 122, 'in-person');
DELETE FROM orders;
DROP TABLE orders;

SELECT * FROM staging_orders;
SELECT * FROM staging_orders LIMIT 10;

/*
    What i need to check:
    (1) (order_id + product_id) is unique or not. 
    (2) what are the duplicated a thousand-ish rows (1850)? Show me the first 100 rows.
    (3) how many rows will I have after I removed the duplicates?
    (4) check from the duplicated rows, within the same group, if all of their values matches except quantity.

    Decision:
    x Combime/ ✔ keep the largest, quntity record within the same group.
*/
-- Q1:
SELECT COUNT(DISTINCT CONCAT(order_id, '_', product_id))
FROM staging_orders; 
-- output: 12110

SELECT COUNT(*)
FROM staging_orders;
-- output: 13079
-- Ans1: No

-- Q2: get not the disctict rows.
SELECT *
FROM staging_orders
WHERE CONCAT(order_id, '_', product_id) IN (
    SELECT CONCAT(order_id, '_', product_id)
    FROM staging_orders
    GROUP BY order_id, product_id
    HAVING COUNT(*) > 1
);
-- Ans2: this query gives the duplicated rows.

-- Q3: count distinct order_ids in all the duplicates
WITH dups_rows AS (
    SELECT *
    FROM staging_orders
    WHERE CONCAT(order_id, '_', product_id) IN (
        SELECT CONCAT(order_id, '_', product_id)
        FROM staging_orders
        GROUP BY order_id, product_id
        HAVING COUNT(*) > 1
    )
)
SELECT COUNT(DISTINCT order_id) 
FROM dups_rows;
-- output: 881. 
/*
    Meaning after removing the duplicates, I have in totoal 
    13079-1850+881 = 12110 
    rows to use.

    Ans 3: 12110
*/ 

-- Q4:
SELECT
    order_id,
    product_id
FROM staging_orders
GROUP BY order_id, product_id
HAVING
    MIN(ordered_at) != MAX(ordered_at) OR
    MIN(customer_id) != MAX(customer_id) OR
    MIN(channel) != MAX(channel);
--output: no data. Meaning quantity is the only col that is different within the same group.

/*
    My original thought process.
    -- Q4-1: If you have the same order_id, do you always have the same ordered_at? Yes
    -- Q4-2: If you have the same order_id, do you always have the same product_id? Yes
    -- Q4-3: If you have the same order_id, do you always have the same customer_id? Yes
    -- Q4-4: If you have the same order_id, do you always have the same channel? Yes
    -- Q4-5: If you have the same order_id, do you always have the same quantity of the product ordered? 


WITH dups_rows AS (
    SELECT *
    FROM staging_orders
    WHERE CONCAT(order_id, '_', product_id) IN (
        SELECT CONCAT(order_id, '_', product_id)
        FROM staging_orders
        GROUP BY order_id, product_id
        HAVING COUNT(*) > 1
    )
) -- find the problematic order_ids
SELECT order_id
FROM dups_rows
GROUP BY order_id
HAVING COUNT(DISTINCT quantity) > 1;


-- what is in distinct order_id from the dups_rows table but not in distinct quantity ?
WITH eightEightOne AS(
    WITH dups_rows AS (
        SELECT *
        FROM staging_orders
        WHERE CONCAT(order_id, '_', product_id) IN (
            SELECT CONCAT(order_id, '_', product_id)
            FROM staging_orders
            GROUP BY order_id, product_id
            HAVING COUNT(*) > 1
        )
    ) -- find the problematic order_ids
    SELECT order_id
    FROM dups_rows
    GROUP BY order_id
), sixNineFive AS(
    WITH dups_rows AS (
        SELECT *
        FROM staging_orders
        WHERE CONCAT(order_id, '_', product_id) IN (
            SELECT CONCAT(order_id, '_', product_id)
            FROM staging_orders
            GROUP BY order_id, product_id
            HAVING COUNT(*) > 1
        )
    ) 
    SELECT order_id
    FROM dups_rows
    GROUP BY order_id
    HAVING COUNT(DISTINCT quantity) > 1;
)
    -- options in the having clause.
    -- Q4-1: HAVING COUNT(DISTINCT ordered_at) > 1;
    -- Q4-2: HAVING COUNT(DISTINCT product_id) > 1;
    -- Q4-3: HAVING COUNT(DISTINCT customer_id) > 1;
    -- Q4-4: HAVING COUNT(DISTINCT channel) > 1;

    -- ans:
    -- Ans4-1: output: none. So all same order_ids, has the same ordered_at.
    -- Ans4-2: output: none. So all same order_ids, has the same product_id.
    -- Ans4-3: output: none. So all same order_ids, has the same customer_id.
    -- Ans4-4: output: none. So all same order_ids, has the same channel.
    -- Ans4-4: output: 695 rows. But not 881?

-- CREATE TABLE test_tab
-- (
--     test_id INT PRIMARY KEY,
--     name TEXT,
--     type TEXT
-- );
-- SELECT count(*) FROM test_tab;
-- DROP TABLE test_tab;

-- counting empty table should return 0 instead of no data

*/

-- Decision: 
SELECT 
    order_id,
    ordered_at,
    product_id,
    MAX(quantity) AS new_quantity,
    customer_id,
    channel
FROM staging_orders
GROUP BY 
    order_id,
    ordered_at,
    product_id,
    customer_id,
    channel
;
-- with results of 12110 rows, matching our aim at Q1 and Q3.
-- This is a table with duplicates removed.

SELECT * FROM orders; 
