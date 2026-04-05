COPY drink_types
FROM 'C:\Users\Lydia\CodeProject\coffee_shop_analysis\csv_files\drink_types.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY food_types
FROM 'C:\Users\Lydia\CodeProject\coffee_shop_analysis\csv_files\food_types.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY ingredients
FROM 'C:\Users\Lydia\CodeProject\coffee_shop_analysis\csv_files\ingredients.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY package_details
FROM 'C:\Users\Lydia\CodeProject\coffee_shop_analysis\csv_files\package_details.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


-- For products_n_prices table. Start here:
-- using staging table to conserve & covert the price data.
CREATE TABLE staging_products (
    product_id TEXT,
    name TEXT,
    size TEXT,
    price TEXT,
    drink_id TEXT,
    food_id TEXT
);

COPY staging_products
FROM 'C:\Users\Lydia\CodeProject\coffee_shop_analysis\csv_files\products_n_prices.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

INSERT INTO products_n_prices (
    product_id,
    name,
    size,
    price,
    drink_id,
    food_id
) SELECT 
    product_id::INT,
    name,
    size,
    REPLACE(price, 'CA$', '')::NUMERIC(4,2),
    NULLIF(drink_id, '')::INT,
    NULLIF(food_id, '')::INT
FROM staging_products;
-- For products_n_prices table. End here.


COPY recipes
FROM 'C:\Users\Lydia\CodeProject\coffee_shop_analysis\csv_files\recipes.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY inventory
FROM 'C:\Users\Lydia\CodeProject\coffee_shop_analysis\csv_files\inventory.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


/* 
    WIP: orders table doesn't exist yet. Currently just staging_orders. Needs cleaning.
    others: N/A -> null 
*/
CREATE TABLE staging_orders (
    order_id TEXT,
    ordered_at TEXT,
    product_id TEXT,
    quantity TEXT, 
    customer_id TEXT,
    channel TEXT
);

COPY staging_orders
FROM 'C:\Users\Lydia\CodeProject\coffee_shop_analysis\csv_files\orders.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Insert cleaned data: duplicate data removed.
INSERT INTO orders (
    order_id,
    ordered_at,
    product_id,
    quantity, 
    customer_id,
    channel
) SELECT 
    order_id::VARCHAR(8),
    ordered_at::TIMESTAMP,
    product_id::INT,
    MAX(quantity)::INT AS new_quantity,
    CASE 
        WHEN customer_id = 'N/A' THEN null
        ELSE customer_id::INT
    END AS customer_id,
    channel
FROM staging_orders
GROUP BY 
    order_id,
    ordered_at,
    product_id,
    customer_id,
    channel
;

