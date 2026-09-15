USE ecommerce_sql_analysis;

-- =========================================================
-- E-COMMERCE SQL ANALYTICS PROJECT
-- CUSTOMER ANALYSIS
-- =========================================================


-- 1. Total unique customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM customers;


-- 2. Customers by state
SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers
GROUP BY customer_state
ORDER BY unique_customers DESC;


-- 3. Orders per customer
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;


-- 4. Top customers by total spending
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC
LIMIT 20;


-- 5. Average customer spending
SELECT
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS average_customer_spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id;


-- 6. Repeat customers
SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        c.customer_unique_id
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
) AS repeat_customer_list;


-- 7. One-time customers
SELECT
    COUNT(*) AS one_time_customers
FROM (
    SELECT
        c.customer_unique_id
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) = 1
) AS one_time_customer_list;


-- 8. Repeat customer percentage
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,
    SUM(total_orders > 1) AS repeat_customers,
    ROUND(
        SUM(total_orders > 1) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;


-- 9. Customer segmentation by spending
WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN total_spending >= 1000 THEN 'High Value'
        WHEN total_spending >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spending), 2) AS segment_revenue,
    ROUND(AVG(total_spending), 2) AS average_spending
FROM customer_spending
GROUP BY
    CASE
        WHEN total_spending >= 1000 THEN 'High Value'
        WHEN total_spending >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END
ORDER BY segment_revenue DESC;


-- 10. Top 20 customers by order frequency
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 20;


-- 11. Customer lifetime spending ranking
WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(total_spending, 2) AS total_spending,
    DENSE_RANK() OVER (
        ORDER BY total_spending DESC
    ) AS customer_rank
FROM customer_spending
ORDER BY customer_rank
LIMIT 20;


-- 12. Customer spending by state
SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- 13. Customer review score analysis
SELECT
    o.order_id,
    c.customer_unique_id,
    r.review_score,
    ROUND(SUM(oi.price), 2) AS order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_reviews r
    ON o.order_id = r.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    c.customer_unique_id,
    r.review_score
ORDER BY order_value DESC
LIMIT 20;


-- 14. Revenue by review score
SELECT
    r.review_score,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_value
FROM order_reviews r
JOIN orders o
    ON r.order_id = o.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY r.review_score
ORDER BY r.review_score;


-- 15. Customer acquisition by month
SELECT
    DATE_FORMAT(
        MIN(o.order_purchase_timestamp),
        '%Y-%m'
    ) AS acquisition_month,
    COUNT(DISTINCT c.customer_unique_id) AS new_customers
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_unique_id
ORDER BY acquisition_month;