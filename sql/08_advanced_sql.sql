USE ecommerce_sql_analysis;

-- =========================================================
-- E-COMMERCE SQL ANALYTICS PROJECT
-- ADVANCED SQL ANALYSIS
-- =========================================================


-- =========================================================
-- 1. Monthly Revenue + Month-over-Month Growth
-- =========================================================

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
    GROUP BY
        DATE_FORMAT(
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
        ) * 100.0 /
        NULLIF(
            LAG(revenue) OVER (
                ORDER BY order_month
            ),
            0
        ),
        2
    ) AS mom_growth_percentage
FROM monthly_sales
ORDER BY order_month;


-- =========================================================
-- 2. Top 3 Products in Each Category
-- =========================================================

WITH product_sales AS (
    SELECT
        COALESCE(
            pct.product_category_name_english,
            p.product_category_name
        ) AS product_category,
        p.product_id,
        SUM(oi.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN product_category_translation pct
        ON p.product_category_name =
           pct.product_category_name
    GROUP BY
        p.product_id,
        p.product_category_name,
        pct.product_category_name_english
),

ranked_products AS (
    SELECT
        product_category,
        product_id,
        revenue,
        DENSE_RANK() OVER (
            PARTITION BY product_category
            ORDER BY revenue DESC
        ) AS category_rank
    FROM product_sales
)

SELECT
    product_category,
    product_id,
    ROUND(revenue, 2) AS revenue,
    category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY
    product_category,
    category_rank;


-- =========================================================
-- 3. Top 3 Sellers in Each State
-- =========================================================

WITH seller_sales AS (
    SELECT
        s.seller_state,
        s.seller_id,
        SUM(oi.price) AS revenue
    FROM sellers s
    JOIN order_items oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_state,
        s.seller_id
),

ranked_sellers AS (
    SELECT
        seller_state,
        seller_id,
        revenue,
        DENSE_RANK() OVER (
            PARTITION BY seller_state
            ORDER BY revenue DESC
        ) AS state_rank
    FROM seller_sales
)

SELECT
    seller_state,
    seller_id,
    ROUND(revenue, 2) AS revenue,
    state_rank
FROM ranked_sellers
WHERE state_rank <= 3
ORDER BY
    seller_state,
    state_rank;


-- =========================================================
-- 4. Customer Revenue Ranking
-- =========================================================

WITH customer_sales AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(revenue, 2) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS customer_rank
FROM customer_sales
ORDER BY customer_rank
LIMIT 100;


-- =========================================================
-- 5. Running Monthly Revenue
-- =========================================================

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
    GROUP BY
        DATE_FORMAT(
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
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ),
        2
    ) AS cumulative_revenue
FROM monthly_sales
ORDER BY order_month;


-- =========================================================
-- 6. Customer Order Frequency Segmentation
-- =========================================================

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
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        WHEN total_orders BETWEEN 2 AND 3
            THEN 'Repeat Customer'
        ELSE 'Loyal Customer'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_customers
FROM customer_orders
GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        WHEN total_orders BETWEEN 2 AND 3
            THEN 'Repeat Customer'
        ELSE 'Loyal Customer'
    END
ORDER BY customer_count DESC;


-- =========================================================
-- 7. Customer First and Last Purchase
-- =========================================================

SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_purchase,
    MAX(o.order_purchase_timestamp) AS last_purchase,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC
LIMIT 100;


-- =========================================================
-- 8. Days Between First and Last Purchase
-- =========================================================

WITH customer_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase,
        MAX(o.order_purchase_timestamp) AS last_purchase
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    first_purchase,
    last_purchase,
    DATEDIFF(
        last_purchase,
        first_purchase
    ) AS customer_lifetime_days
FROM customer_purchase
WHERE first_purchase <> last_purchase
ORDER BY customer_lifetime_days DESC;


-- =========================================================
-- 9. Product Revenue Contribution
-- =========================================================

WITH product_sales AS (
    SELECT
        p.product_id,
        SUM(oi.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id
)

SELECT
    product_id,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_percentage
FROM product_sales
ORDER BY revenue DESC
LIMIT 50;


-- =========================================================
-- 10. Revenue by Payment Type
-- =========================================================

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS payment_revenue,
    ROUND(
        SUM(payment_value) * 100.0 /
        SUM(SUM(payment_value)) OVER (),
        2
    ) AS revenue_percentage
FROM order_payments
GROUP BY payment_type
ORDER BY payment_revenue DESC;


-- =========================================================
-- 11. Review Score + Revenue Analysis
-- =========================================================

SELECT
    r.review_score,
    COUNT(DISTINCT r.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM order_reviews r
JOIN order_items oi
    ON r.order_id = oi.order_id
GROUP BY r.review_score
ORDER BY r.review_score;


-- =========================================================
-- 12. High-Value Customer Identification
-- =========================================================

WITH customer_sales AS (
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
    CASE
        WHEN total_spending >= 2000
            THEN 'VIP'
        WHEN total_spending >= 1000
            THEN 'High Value'
        WHEN total_spending >= 500
            THEN 'Medium Value'
        ELSE 'Standard'
    END AS customer_segment
FROM customer_sales
ORDER BY total_spending DESC;


-- =========================================================
-- 13. Monthly Order Volume
-- =========================================================

WITH monthly_orders AS (
    SELECT
        DATE_FORMAT(
            order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY
        DATE_FORMAT(
            order_purchase_timestamp,
            '%Y-%m'
        )
)

SELECT
    order_month,
    total_orders,
    ROUND(
        AVG(total_orders) OVER (
            ORDER BY order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average
FROM monthly_orders
ORDER BY order_month;


-- =========================================================
-- 14. Delivery Performance by State
-- =========================================================

WITH state_delivery AS (
    SELECT
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS total_orders,
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ) AS avg_delivery_days
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY c.customer_state
)

SELECT
    customer_state,
    total_orders,
    ROUND(avg_delivery_days, 2) AS average_delivery_days,
    DENSE_RANK() OVER (
        ORDER BY avg_delivery_days
    ) AS delivery_rank
FROM state_delivery
ORDER BY delivery_rank;


-- =========================================================
-- 15. Category Performance Classification
-- =========================================================

WITH category_sales AS (
    SELECT
        COALESCE(
            pct.product_category_name_english,
            p.product_category_name
        ) AS product_category,
        COUNT(*) AS units_sold,
        SUM(oi.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN product_category_translation pct
        ON p.product_category_name =
           pct.product_category_name
    GROUP BY
        p.product_category_name,
        pct.product_category_name_english
)

SELECT
    product_category,
    units_sold,
    ROUND(revenue, 2) AS revenue,
    CASE
        WHEN revenue >= 500000
            THEN 'High Performing'
        WHEN revenue >= 100000
            THEN 'Medium Performing'
        ELSE 'Low Performing'
    END AS performance_category
FROM category_sales
ORDER BY revenue DESC;