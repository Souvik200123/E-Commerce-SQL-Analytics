USE ecommerce_sql_analysis;

-- =========================================================
-- E-COMMERCE SQL ANALYTICS PROJECT
-- DATA EXPLORATION
-- =========================================================


-- 1. Check all tables
SHOW TABLES;


-- 2. Check customers
SELECT *
FROM customers
LIMIT 10;


-- 3. Check orders
SELECT *
FROM orders
LIMIT 10;


-- 4. Check order items
SELECT *
FROM order_items
LIMIT 10;


-- 5. Check products
SELECT *
FROM products
LIMIT 10;


-- 6. Check sellers
SELECT *
FROM sellers
LIMIT 10;


-- 7. Check payments
SELECT *
FROM order_payments
LIMIT 10;


-- 8. Check reviews
SELECT *
FROM order_reviews
LIMIT 10;


-- 9. Check product categories
SELECT *
FROM product_category_translation
LIMIT 10;


-- 10. Order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 11. Payment type analysis
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- 12. Review score distribution
SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- 13. Customers by state
SELECT
    customer_state,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;


-- 14. Sellers by state
SELECT
    seller_state,
    COUNT(*) AS total_sellers
FROM sellers
GROUP BY seller_state
ORDER BY total_sellers DESC;


-- 15. Top product categories by number of products
SELECT
    product_category_name,
    COUNT(*) AS total_products
FROM products
GROUP BY product_category_name
ORDER BY total_products DESC
LIMIT 20;