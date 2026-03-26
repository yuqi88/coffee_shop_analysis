-- Create package_details with primary
CREATE TABLE package_details
(
    pac_id INT PRIMARY KEY,
    unit TEXT,
    price_per_unit NUMERIC(5,2),
    quantity_per_unit INT,
    measured_by TEXT
);

-- Create inventory table with primary & foreign key
CREATE TABLE inventory
(
    inv_id INT PRIMARY KEY, 
    ing_id INT,
    quantity INT,
    unit TEXT,
    pac_id INT,
    FOREIGN KEY (ing_id) REFERENCES ingredients (ing_id),
    FOREIGN KEY (pac_id) REFERENCES package_details (pac_id)
);



-- Create indexes on foreign key columns for better performance
CREATE INDEX idx_pac_id ON inventory (pac_id);

CREATE INDEX idx_inventory_ing_id ON inventory (ing_id);
ALTER INDEX idx_ing_id RENAME TO idx_recipes_ing_id;
