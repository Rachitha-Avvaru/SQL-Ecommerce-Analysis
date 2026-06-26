-- ============================================================
-- E-COMMERCE SALES ANALYSIS - SQL PROJECT
-- Author  : Rachitha Avvaru
-- Tool    : MySQL 8.0
-- GitHub  : github.com/Rachitha-Avvaru
-- Purpose : Demonstrate SQL skills for Data Analytics portfolio
-- ============================================================


-- ============================================================
-- SECTION 1: SCHEMA CREATION
-- ============================================================

CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  name        VARCHAR(100),
  email       VARCHAR(100),
  city        VARCHAR(50),
  created_at  DATE
);

CREATE TABLE products (
  product_id   INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(100),
  category     VARCHAR(50),
  price        DECIMAL(10,2)
);

CREATE TABLE orders (
  order_id    INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT,
  order_date  DATE,
  status      VARCHAR(20),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
  item_id    INT PRIMARY KEY AUTO_INCREMENT,
  order_id   INT,
  product_id INT,
  quantity   INT,
  unit_price DECIMAL(10,2),
  FOREIGN KEY (order_id)   REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- ============================================================
-- SECTION 2: SAMPLE DATA
-- ============================================================

INSERT INTO customers VALUES
(1, 'Priya Sharma',   'priya@gmail.com',  'Mumbai',    '2023-01-15'),
(2, 'Rahul Verma',    'rahul@gmail.com',  'Delhi',     '2023-02-20'),
(3, 'Anjali Nair',    'anjali@gmail.com', 'Bangalore', '2023-03-10'),
(4, 'Kiran Reddy',    'kiran@gmail.com',  'Hyderabad', '2023-04-05'),
(5, 'Sneha Joshi',    'sneha@gmail.com',  'Pune',      '2023-05-18'),
(6, 'Amit Kulkarni',  'amit@gmail.com',   'Chennai',   '2023-06-01');

INSERT INTO products VALUES
(1, 'Laptop',       'Electronics', 55000.00),
(2, 'Smartphone',   'Electronics', 22000.00),
(3, 'Headphones',   'Electronics',  3500.00),
(4, 'Desk Chair',   'Furniture',    8000.00),
(5, 'Notebook Set', 'Stationery',    450.00);

INSERT INTO orders VALUES
(1, 1, '2023-06-01', 'Delivered'),
(2, 2, '2023-06-05', 'Delivered'),
(3, 3, '2023-06-10', 'Shipped'),
(4, 4, '2023-06-15', 'Pending'),
(5, 1, '2023-07-01', 'Delivered'),
(6, 5, '2023-07-10', 'Delivered');

INSERT INTO order_items VALUES
(1, 1, 1, 1, 55000.00),
(2, 1, 3, 2,  3500.00),
(3, 2, 2, 1, 22000.00),
(4, 3, 4, 1,  8000.00),
(5, 4, 5, 3,   450.00),
(6, 5, 2, 1, 22000.00),
(7, 5, 3, 1,  3500.00),
(8, 6, 1, 1, 55000.00);


-- ============================================================
-- SECTION 3: ANALYSIS QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- Query 1: Customer Spending Summary
-- Shows total orders and total amount spent per customer
-- Skills: JOIN, GROUP BY, ORDER BY, Aggregate functions
-- ------------------------------------------------------------
SELECT
  c.name,
  COUNT(o.order_id)                AS total_orders,
  SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY c.name
ORDER BY total_spent DESC;


-- ------------------------------------------------------------
-- Query 2: Top Selling Products by Revenue
-- Identifies which products generate the most revenue
-- Skills: JOIN, GROUP BY, SUM, ORDER BY
-- ------------------------------------------------------------
SELECT
  p.product_name,
  p.category,
  SUM(oi.quantity)                 AS units_sold,
  SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- Query 3: Monthly Sales Trend
-- Tracks revenue month by month to spot growth patterns
-- Skills: DATE_FORMAT, GROUP BY, ORDER BY
-- ------------------------------------------------------------
SELECT
  DATE_FORMAT(o.order_date, '%Y-%m') AS month,
  COUNT(DISTINCT o.order_id)         AS total_orders,
  SUM(oi.quantity * oi.unit_price)   AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;


-- ------------------------------------------------------------
-- Query 4: Category-wise Revenue Breakdown
-- Shows which product category contributes most to revenue
-- Skills: JOIN, GROUP BY, SUM, ORDER BY
-- ------------------------------------------------------------
SELECT
  p.category,
  COUNT(DISTINCT oi.order_id)      AS orders_count,
  SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;


-- ------------------------------------------------------------
-- Query 5: Customers Who Have Never Placed an Order
-- Finds inactive customers using LEFT JOIN + NULL check
-- Skills: LEFT JOIN, IS NULL, filtering
-- ------------------------------------------------------------
SELECT
  c.customer_id,
  c.name,
  c.email,
  c.city
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- ------------------------------------------------------------
-- Query 6: Average Order Value per Customer
-- Measures how much each customer spends per order on average
-- Skills: Subquery, AVG, JOIN, GROUP BY
-- ------------------------------------------------------------
SELECT
  c.name,
  ROUND(AVG(order_total), 2) AS avg_order_value
FROM customers c
JOIN (
  SELECT
    o.customer_id,
    o.order_id,
    SUM(oi.quantity * oi.unit_price) AS order_total
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY o.customer_id, o.order_id
) AS order_summary ON c.customer_id = order_summary.customer_id
GROUP BY c.name
ORDER BY avg_order_value DESC;


-- ------------------------------------------------------------
-- Query 7: Repeat vs One-Time Customers
-- Classifies customers based on purchase frequency
-- Skills: CASE WHEN, GROUP BY, ORDER BY
-- ------------------------------------------------------------
SELECT
  c.name,
  COUNT(o.order_id) AS total_orders,
  CASE
    WHEN COUNT(o.order_id) > 1 THEN 'Repeat Customer'
    ELSE 'One-Time Customer'
  END AS customer_type
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name
ORDER BY total_orders DESC;


-- ------------------------------------------------------------
-- Query 8: Order Status Breakdown
-- Shows how many orders are in each status stage
-- Skills: GROUP BY, COUNT, subquery, percentage calculation
-- ------------------------------------------------------------
SELECT
  status,
  COUNT(order_id) AS order_count,
  ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 1) AS percentage
FROM orders
GROUP BY status
ORDER BY order_count DESC;