-- =====================================================================
-- Day 1: Create the store database tables and load sample data
-- Run with:  psql -d store_sales -f sql/01_setup.sql
-- Safe to rerun: it drops the tables first, then rebuilds them.
-- =====================================================================

-- Start clean. CASCADE also removes the foreign keys that point at a table.
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders      CASCADE;
DROP TABLE IF EXISTS products    CASCADE;
DROP TABLE IF EXISTS categories  CASCADE;
DROP TABLE IF EXISTS customers   CASCADE;

-- ---------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------

-- Each customer gets an id that PostgreSQL fills in automatically.
CREATE TABLE customers (
    customer_id  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name   TEXT NOT NULL,
    last_name    TEXT NOT NULL,
    email        TEXT NOT NULL UNIQUE,
    city         TEXT,
    country      TEXT NOT NULL,
    signup_date  DATE NOT NULL
);

CREATE TABLE categories (
    category_id  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         TEXT NOT NULL UNIQUE
);

-- NUMERIC(10,2) stores money exactly (no floating point rounding).
CREATE TABLE products (
    product_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         TEXT NOT NULL,
    category_id  INTEGER NOT NULL REFERENCES categories (category_id),
    price        NUMERIC(10,2) NOT NULL CHECK (price >= 0)
);

-- One row per checkout. Status lets us practice filtering out cancellations.
CREATE TABLE orders (
    order_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES customers (customer_id),
    order_date   DATE NOT NULL,
    status       TEXT NOT NULL CHECK (status IN ('completed', 'shipped', 'cancelled'))
);

-- The lines inside an order. unit_price is copied at the time of sale,
-- because a product's list price can change later.
CREATE TABLE order_items (
    order_item_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      INTEGER NOT NULL REFERENCES orders (order_id),
    product_id    INTEGER NOT NULL REFERENCES products (product_id),
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- ---------------------------------------------------------------------
-- Sample data
-- Ids are generated in insert order, so the first row below is id 1.
-- ---------------------------------------------------------------------

INSERT INTO customers (first_name, last_name, email, city, country, signup_date) VALUES
    ('Ava',     'Johnson',  'ava.johnson@example.com',   'New York',  'USA',       '2025-11-02'),
    ('Liam',    'Smith',    'liam.smith@example.com',    'Toronto',   'Canada',    '2025-11-15'),
    ('Mia',     'Garcia',   'mia.garcia@example.com',    'Madrid',    'Spain',     '2025-12-01'),
    ('Noah',    'Brown',    'noah.brown@example.com',    'London',    'UK',        '2025-12-10'),
    ('Emma',    'Davis',    'emma.davis@example.com',    'Chicago',   'USA',       '2026-01-05'),
    ('Lucas',   'Martin',   'lucas.martin@example.com',  'Paris',     'France',    '2026-01-12'),
    ('Sofia',   'Rossi',    'sofia.rossi@example.com',   'Rome',      'Italy',     '2026-01-20'),
    ('Ethan',   'Wilson',   'ethan.wilson@example.com',  'Austin',    'USA',       '2026-02-03'),
    ('Chloe',   'Tremblay', 'chloe.t@example.com',       'Montreal',  'Canada',    '2026-02-14'),
    ('Oliver',  'Taylor',   'oliver.taylor@example.com', 'Manchester','UK',        '2026-03-01'),
    ('Hana',    'Sato',     'hana.sato@example.com',     'Tokyo',     'Japan',     '2026-03-18'),
    ('Mateo',   'Lopez',    'mateo.lopez@example.com',   'Mexico City','Mexico',   '2026-04-02');

INSERT INTO categories (name) VALUES
    ('Electronics'),   -- 1
    ('Books'),         -- 2
    ('Home & Kitchen'),-- 3
    ('Sports'),        -- 4
    ('Clothing');      -- 5

INSERT INTO products (name, category_id, price) VALUES
    ('Wireless Earbuds',        1,  59.99),  -- 1
    ('USB-C Charger',           1,  19.99),  -- 2
    ('Bluetooth Speaker',       1,  45.00),  -- 3
    ('SQL for Beginners',       2,  29.95),  -- 4
    ('Data Analysis Handbook',  2,  39.50),  -- 5
    ('Mystery Novel',           2,  14.99),  -- 6
    ('Coffee Maker',            3,  89.00),  -- 7
    ('Chef Knife',              3,  34.99),  -- 8
    ('Ceramic Mug Set',         3,  24.00),  -- 9
    ('Yoga Mat',                4,  25.00),  -- 10
    ('Running Shoes',           4,  95.00),  -- 11
    ('Water Bottle',            4,  12.50),  -- 12
    ('Hoodie',                  5,  42.00),  -- 13
    ('Rain Jacket',             5,  75.00),  -- 14
    ('Wool Socks (3 pack)',     5,  15.00);  -- 15

INSERT INTO orders (customer_id, order_date, status) VALUES
    (1,  '2026-01-08', 'completed'),  -- 1
    (2,  '2026-01-14', 'completed'),  -- 2
    (3,  '2026-01-22', 'completed'),  -- 3
    (1,  '2026-01-30', 'completed'),  -- 4
    (5,  '2026-02-04', 'completed'),  -- 5
    (4,  '2026-02-11', 'cancelled'),  -- 6
    (6,  '2026-02-17', 'completed'),  -- 7
    (7,  '2026-02-25', 'completed'),  -- 8
    (2,  '2026-03-03', 'completed'),  -- 9
    (8,  '2026-03-09', 'completed'),  -- 10
    (9,  '2026-03-15', 'completed'),  -- 11
    (1,  '2026-03-21', 'completed'),  -- 12
    (10, '2026-03-28', 'cancelled'),  -- 13
    (5,  '2026-04-04', 'completed'),  -- 14
    (11, '2026-04-10', 'completed'),  -- 15
    (3,  '2026-04-18', 'completed'),  -- 16
    (12, '2026-04-25', 'completed'),  -- 17
    (4,  '2026-05-02', 'completed'),  -- 18
    (8,  '2026-05-09', 'completed'),  -- 19
    (6,  '2026-05-16', 'completed'),  -- 20
    (1,  '2026-05-23', 'completed'),  -- 21
    (9,  '2026-05-30', 'cancelled'),  -- 22
    (7,  '2026-06-06', 'completed'),  -- 23
    (2,  '2026-06-13', 'shipped'),    -- 24
    (11, '2026-06-20', 'shipped'),    -- 25
    (5,  '2026-06-27', 'shipped');    -- 26
-- Customer 10 only ever cancelled, so they never completed a purchase.

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1,  1,  1, 59.99), (1,  2,  2, 19.99),
    (2,  4,  1, 29.95), (2,  5,  1, 39.50),
    (3,  7,  1, 89.00), (3,  9,  1, 24.00),
    (4,  6,  3, 14.99),
    (5,  11, 1, 95.00), (5,  12, 2, 12.50),
    (6,  3,  1, 45.00),
    (7,  13, 2, 42.00), (7,  15, 1, 15.00),
    (8,  8,  1, 34.99), (8,  9,  2, 24.00),
    (9,  1,  1, 59.99),
    (10, 10, 1, 25.00), (10, 12, 1, 12.50), (10, 11, 1, 95.00),
    (11, 14, 1, 75.00),
    (12, 4,  1, 29.95), (12, 5,  1, 39.50), (12, 6,  1, 14.99),
    (13, 7,  1, 89.00),
    (14, 3,  1, 45.00), (14, 2,  1, 19.99),
    (15, 1,  2, 59.99),
    (16, 13, 1, 42.00),
    (17, 10, 2, 25.00), (17, 15, 2, 15.00),
    (18, 7,  1, 85.00),   -- sold during a sale, below list price
    (19, 11, 1, 95.00),
    (20, 5,  2, 39.50),
    (21, 1,  1, 59.99), (21, 3,  1, 45.00),
    (22, 14, 1, 75.00),
    (23, 9,  1, 24.00), (23, 8,  1, 34.99),
    (24, 2,  3, 19.99),
    (25, 6,  2, 14.99), (25, 4,  1, 29.95),
    (26, 12, 4, 12.50), (26, 10, 1, 25.00);

-- ---------------------------------------------------------------------
-- Quick check: row counts per table. You should see
-- customers 12, categories 5, products 15, orders 26, order_items 42.
-- ---------------------------------------------------------------------
SELECT 'customers'   AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'categories',  COUNT(*) FROM categories
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;
