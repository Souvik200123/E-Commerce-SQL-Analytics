USE ecommerce_sql_analysis;

-- =========================================================
-- E-COMMERCE SQL ANALYTICS PROJECT
-- SALES & REVENUE ANALYSIS
-- =========================================================


-- 1. Total number of orders
SELECT
    COUNT(*) AS total_orders
FROM orders;


-- 2. Total customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM customers;


-- 3. Total products sold
SELECT
    SUM(order_item_count) AS total_products_sold
FROM (
    SELECT
        order_id,
        COUNT(*) AS order_item_count
    FROM order_items
    GROUP BY order_id
) AS order_counts;


-- 4. Total revenue
SELECT
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items;


-- 5. Total freight cost
SELECT
    ROUND(SUM(freight_value), 2) AS total_freight
FROM order_items;


-- 6. Total revenue including freight
SELECT
    ROUND(SUM(price + freight_value), 2) AS total_sales_value
FROM order_items;


-- 7. Average order value
SELECT
    ROUND(
        SUM(price) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM order_items;


-- 8. Monthly revenue
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;


-- 9. Monthly revenue including freight
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS monthly_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;


-- 10. Revenue by order status
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY revenue DESC;


-- 11. Revenue by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- 12. Average order value by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY average_order_value DESC;


-- 13. Top 10 sellers by revenue
SELECT
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_state
ORDER BY revenue DESC
LIMIT 10;


-- 14. Top 10 products by revenue
SELECT
    p.product_id,
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name
    ) AS product_category,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY
    p.product_id,
    p.product_category_name,
    pct.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;


-- 15. Top 10 product categories by revenue
SELECT
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name
    ) AS product_category,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY
    p.product_category_name,
    pct.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;


-- 16. Revenue contribution by product category
SELECT
    product_category,
    revenue,
    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_percentage
FROM (
    SELECT
        COALESCE(
            pct.product_category_name_english,
            p.product_category_name
        ) AS product_category,
        SUM(oi.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN product_category_translation pct
        ON p.product_category_name = pct.product_category_name
    GROUP BY
        p.product_category_name,
        pct.product_category_name_english
) AS category_sales
ORDER BY revenue DESC;


-- 17. Monthly revenue with previous month comparison
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    )
)

SELECT
    order_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        LAG(revenue) OVER (
            ORDER BY order_month
        ),
        2
    ) AS previous_month_revenue,
    ROUND(
        (
            revenue -
            LAG(revenue) OVER (
                ORDER BY order_month
            )
        )
        * 100.0
        /
        NULLIF(
            LAG(revenue) OVER (
                ORDER BY order_month
            ),
            0
        ),
        2
    ) AS month_over_month_growth_percentage
FROM monthly_sales
ORDER BY order_month;


-- 18. Running cumulative revenue
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    )
)

SELECT
    order_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY order_month
        ),
        2
    ) AS cumulative_revenue
FROM monthly_sales
ORDER BY order_month;


-- 19. Revenue ranking by customer state
SELECT
    customer_state,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM (
    SELECT
        c.customer_state,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_state
) AS state_sales
ORDER BY revenue_rank;


-- 20. High-value orders
SELECT
    o.order_id,
    o.customer_id,
    ROUND(SUM(oi.price), 2) AS order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    o.customer_id
HAVING SUM(oi.price) > 1000
ORDER BY order_value DESC;