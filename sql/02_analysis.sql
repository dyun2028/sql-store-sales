-- =====================================================================
-- Store sales analysis: four business questions, answered in SQL
-- Run after 01_setup.sql:  psql -d store_sales -f sql/02_analysis.sql
-- Cancelled orders are excluded everywhere, since they earned nothing.
-- =====================================================================

-- A reusable view: one row per order line, with its revenue.
CREATE OR REPLACE VIEW sales AS
SELECT o.order_id,
       o.order_date,
       o.customer_id,
       c.country,
       p.name          AS product,
       cat.name        AS category,
       oi.quantity,
       oi.quantity * oi.unit_price AS revenue
FROM order_items oi
JOIN orders     o   ON o.order_id     = oi.order_id
JOIN customers  c   ON c.customer_id  = o.customer_id
JOIN products   p   ON p.product_id   = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
WHERE o.status <> 'cancelled';


-- Q1. How is revenue trending month to month?
-- Uses DATE_TRUNC to bucket dates, and LAG to compare with last month.
SELECT TO_CHAR(DATE_TRUNC('month', order_date), 'YYYY-MM') AS month,
       COUNT(DISTINCT order_id)                            AS orders,
       SUM(revenue)                                        AS revenue,
       SUM(revenue) - LAG(SUM(revenue)) OVER (ORDER BY DATE_TRUNC('month', order_date))
                                                           AS change_vs_last_month
FROM sales
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;


-- Q2. Which categories bring in the most money, and what share of the total?
-- A window function over the grouped result gives the percent of total.
SELECT category,
       SUM(revenue) AS revenue,
       ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS pct_of_total
FROM sales
GROUP BY category
ORDER BY revenue DESC;


-- Q3. What are the top 5 products by revenue?
-- RANK() handles ties fairly if two products earn the same.
SELECT *
FROM (
    SELECT product,
           category,
           SUM(quantity) AS units_sold,
           SUM(revenue)  AS revenue,
           RANK() OVER (ORDER BY SUM(revenue) DESC) AS rnk
    FROM sales
    GROUP BY product, category
) ranked
WHERE rnk <= 5
ORDER BY rnk;


-- Q4. How many customers come back, and are they worth more?
-- A CTE builds one row per customer, then CASE labels them.
WITH per_customer AS (
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS orders,
           SUM(revenue)             AS lifetime_revenue
    FROM sales
    GROUP BY customer_id
)
SELECT CASE WHEN orders > 1 THEN 'repeat' ELSE 'one-time' END AS customer_type,
       COUNT(*)                         AS customers,
       ROUND(AVG(lifetime_revenue), 2)  AS avg_lifetime_revenue,
       SUM(lifetime_revenue)            AS total_revenue
FROM per_customer
GROUP BY customer_type
ORDER BY customer_type DESC;
