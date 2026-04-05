-- Create products_n_prices table with primary & foreign key
CREATE TABLE products_n_prices 
(
    product_id INT PRIMARY KEY,
    name TEXT,
    size TEXT,
    price NUMERIC(4,2),
    drink_id INT,
    food_id INT,
    FOREIGN KEY (drink_id) REFERENCES drink_types (drink_id),
    FOREIGN KEY (food_id) REFERENCES food_types (food_id)
);

-- Create recipes table with a composite primary key and foreign keys
CREATE TABLE recipes
(
    product_id INT,
    ing_id INT,
    quantity INT,
    PRIMARY KEY (product_id, ing_id),
    FOREIGN KEY (product_id) REFERENCES products_n_prices (product_id),
    FOREIGN KEY (ing_id) REFERENCES ingredients (ing_id)
);

-- Create orders table with a composite primary key and foreign keys
CREATE TABLE orders
(
    order_id VARCHAR(8),
    ordered_at TIMESTAMP,
    product_id INT,
    quantity INT, 
    customer_id INT,
    channel TEXT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES products_n_prices (product_id)
);

-- Create indexes on foreign key columns for better performance
CREATE INDEX idx_drink_id ON products_n_prices (drink_id);
CREATE INDEX idx_food_id ON products_n_prices (food_id);
CREATE INDEX idx_recipe_product_id ON recipes (product_id);
CREATE INDEX idx_ing_id ON recipes (ing_id);
CREATE INDEX idx_order_product_id ON orders (product_id); -- cannot have 2 idx_product_id in the same schema, even for different table.