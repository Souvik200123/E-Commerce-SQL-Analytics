USE ecommerce_sql_analysis;

-- =========================================================
-- E-COMMERCE SQL ANALYTICS PROJECT
-- PRODUCT ANALYSIS
-- =========================================================


-- 1. Total number of products
SELECT
    COUNT(*) AS total_products
FROM products;


-- 2. Products by category
SELECT
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name
    ) AS product_category,
    COUNT(*) AS total_products
FROM products p
LEFT JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY
    p.product_category_name,
    pct.product_category_name_english
ORDER BY total_products DESC;


-- 3. Top 20 categories by units sold
SELECT
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name
    ) AS product_category,
    COUNT(*) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY
    p.product_category_name,
    pct.product_category_name_english
ORDER BY units_sold DESC
LIMIT 20;


-- 4. Top 20 categories by revenue
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
LIMIT 20;


-- 5. Average selling price by category
SELECT
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name
    ) AS product_category,
    ROUND(AVG(oi.price), 2) AS average_price,
    COUNT(*) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY
    p.product_category_name,
    pct.product_category_name_english
HAVING COUNT(*) >= 50
ORDER BY average_price DESC;


-- 6. Top 20 individual products by revenue
SELECT
    p.product_id,
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name
    ) AS product_category,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_price
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
LIMIT 20;


-- 7. Top 20 products by units sold
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
ORDER BY units_sold DESC
LIMIT 20;


-- 8. Product revenue ranking
WITH product_sales AS (
    SELECT
        p.product_id,
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
        p.product_id,
        p.product_category_name,
        pct.product_category_name_english
)

SELECT
    product_id,
    product_category,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM product_sales
ORDER BY revenue_rank
LIMIT 20;


-- 9. Category revenue contribution
WITH category_sales AS (
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
)

SELECT
    product_category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_percentage
FROM category_sales
ORDER BY revenue DESC;


-- 10. Cumulative category revenue
WITH category_sales AS (
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
)

SELECT
    product_category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ),
        2
    ) AS cumulative_revenue
FROM category_sales
ORDER BY revenue DESC;


-- 11. Products with no sales
SELECT
    p.product_id,
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name
    ) AS product_category
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
WHERE oi.product_id IS NULL
ORDER BY product_category;


-- 12. Count of products with no sales
SELECT
    COUNT(*) AS products_without_sales
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- 13. Seller product performance
SELECT
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.product_id) AS unique_products_sold,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_id,
    s.seller_state
ORDER BY revenue DESC
LIMIT 20;


-- 14. Seller revenue ranking
WITH seller_sales AS (
    SELECT
        s.seller_id,
        s.seller_state,
        SUM(oi.price) AS revenue
    FROM sellers s
    JOIN order_items oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_id,
        s.seller_state
)

SELECT
    seller_id,
    seller_state,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS seller_rank
FROM seller_sales
ORDER BY seller_rank
LIMIT 20;


-- 15. Seller average order value
SELECT
    s.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_id
HAVING COUNT(DISTINCT oi.order_id) >= 10
ORDER BY average_order_value DESC
LIMIT 20;