-- Create drink_types table with primary key
CREATE TABLE drink_types
(
    drink_id INT PRIMARY KEY,
    name TEXT,
    hot BOOLEAN,
    cold BOOLEAN,
    small_hot_only BOOLEAN,
    medium BOOLEAN,
    large BOOLEAN,
    caffeine_level TEXT
);

-- Create food_types table with primary key
CREATE TABLE food_types
(
    food_id INT PRIMARY KEY,
    name TEXT,
    type TEXT
);

-- Create ingredients table with primary key
CREATE TABLE ingredients
(
    ing_id INT PRIMARY KEY,
    name TEXT,
    quantity NUMERIC,
    measure_by TEXT
);



