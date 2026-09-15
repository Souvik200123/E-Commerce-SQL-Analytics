USE ecommerce_sql_analysis;

-- =========================================================
-- E-COMMERCE SQL ANALYTICS PROJECT
-- DATA QUALITY CHECKS
-- =========================================================


-- 1. Check NULL values in customers
SELECT
    COUNT(*) AS total_rows,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(customer_unique_id IS NULL) AS null_customer_unique_id,
    SUM(customer_city IS NULL) AS null_customer_city,
    SUM(customer_state IS NULL) AS null_customer_state
FROM customers;


-- 2. Check NULL values in orders
SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(order_status IS NULL) AS null_order_status,
    SUM(order_purchase_timestamp IS NULL) AS null_purchase_date,
    SUM(order_approved_at IS NULL) AS null_approved_date,
    SUM(order_delivered_customer_date IS NULL) AS null_delivery_date
FROM orders;


-- 3. Check NULL values in order items
SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(seller_id IS NULL) AS null_seller_id,
    SUM(price IS NULL) AS null_price,
    SUM(freight_value IS NULL) AS null_freight
FROM order_items;


-- 4. Check NULL values in products
SELECT
    COUNT(*) AS total_rows,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(product_category_name IS NULL) AS null_category,
    SUM(product_weight_g IS NULL) AS null_weight,
    SUM(product_length_cm IS NULL) AS null_length,
    SUM(product_height_cm IS NULL) AS null_height,
    SUM(product_width_cm IS NULL) AS null_width
FROM products;


-- 5. Check duplicate customer IDs
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- 6. Check duplicate order IDs
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- 7. Check duplicate product IDs
SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- 8. Check invalid prices
SELECT
    COUNT(*) AS invalid_price_rows
FROM order_items
WHERE price <= 0;


-- 9. Check invalid freight values
SELECT
    COUNT(*) AS invalid_freight_rows
FROM order_items
WHERE freight_value < 0;


-- 10. Check invalid review scores
SELECT
    COUNT(*) AS invalid_review_scores
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;


-- 11. Check order date range
SELECT
    MIN(order_purchase_timestamp) AS earliest_order,
    MAX(order_purchase_timestamp) AS latest_order
FROM orders;


-- 12. Check orders where delivery happened before purchase
SELECT
    COUNT(*) AS invalid_delivery_dates
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date < order_purchase_timestamp;


-- 13. Check orders where approval happened before purchase
SELECT
    COUNT(*) AS invalid_approval_dates
FROM orders
WHERE order_approved_at IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_approved_at < order_purchase_timestamp;


-- 14. Check order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 15. Overall data-quality summary
SELECT
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM sellers) AS sellers,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(*) FROM order_items) AS order_items,
    (SELECT COUNT(*) FROM order_payments) AS payments,
    (SELECT COUNT(*) FROM order_reviews) AS reviews,
    (SELECT COUNT(*) FROM geolocation) AS geolocation_rows,
    (SELECT COUNT(*) FROM product_category_translation) AS translated_categories;