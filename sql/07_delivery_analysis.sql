USE ecommerce_sql_analysis;

-- =========================================================
-- E-COMMERCE SQL ANALYTICS PROJECT
-- DELIVERY & LOGISTICS ANALYSIS
-- =========================================================


-- 1. Average delivery time in days
SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- 2. Minimum and maximum delivery time
SELECT
    MIN(
        DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )
    ) AS minimum_delivery_days,
    MAX(
        DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )
    ) AS maximum_delivery_days,
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- 3. Estimated vs actual delivery performance
SELECT
    COUNT(*) AS delivered_orders,
    SUM(
        order_delivered_customer_date <=
        order_estimated_delivery_date
    ) AS delivered_on_or_before_estimate,
    SUM(
        order_delivered_customer_date >
        order_estimated_delivery_date
    ) AS delivered_late
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- 4. On-time delivery percentage
SELECT
    ROUND(
        SUM(
            order_delivered_customer_date <=
            order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- 5. Late delivery percentage
SELECT
    ROUND(
        SUM(
            order_delivered_customer_date >
            order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- 6. Delivery performance by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days,
    ROUND(
        SUM(
            o.order_delivered_customer_date <=
            o.order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_percentage
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY average_delivery_days;


-- 7. Delivery performance by seller state
SELECT
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_state
ORDER BY average_delivery_days;


-- 8. Delivery status classification
SELECT
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'
        WHEN order_delivered_customer_date <=
             order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'
        WHEN order_delivered_customer_date <=
             order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END
ORDER BY total_orders DESC;


-- 9. Average delay for late deliveries
SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_estimated_delivery_date
            )
        ),
        2
    ) AS average_delay_days
FROM orders
WHERE order_delivered_customer_date >
      order_estimated_delivery_date;


-- 10. Maximum delivery delay
SELECT
    MAX(
        DATEDIFF(
            order_delivered_customer_date,
            order_estimated_delivery_date
        )
    ) AS maximum_delay_days
FROM orders
WHERE order_delivered_customer_date >
      order_estimated_delivery_date;


-- 11. Top 20 orders with the longest delivery time
SELECT
    order_id,
    customer_id,
    DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    ) AS delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
ORDER BY delivery_days DESC
LIMIT 20;


-- 12. Orders with significant delivery delays
SELECT
    order_id,
    customer_id,
    DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date
    ) AS delay_days
FROM orders
WHERE order_delivered_customer_date >
      order_estimated_delivery_date
ORDER BY delay_days DESC
LIMIT 20;


-- 13. Delivery time by order status
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY order_status
ORDER BY average_delivery_days;


-- 14. Freight cost vs delivery time
SELECT
    CASE
        WHEN oi.freight_value < 20 THEN 'Low Freight'
        WHEN oi.freight_value < 50 THEN 'Medium Freight'
        ELSE 'High Freight'
    END AS freight_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days,
    ROUND(AVG(oi.freight_value), 2) AS average_freight
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE
        WHEN oi.freight_value < 20 THEN 'Low Freight'
        WHEN oi.freight_value < 50 THEN 'Medium Freight'
        ELSE 'High Freight'
    END
ORDER BY average_delivery_days;


-- 15. Monthly delivery performance
SELECT
    DATE_FORMAT(
        order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days,
    ROUND(
        SUM(
            order_delivered_customer_date <=
            order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY
    DATE_FORMAT(
        order_purchase_timestamp,
        '%Y-%m'
    )
ORDER BY order_month;


-- 16. Delivery time ranking by customer state
WITH state_delivery AS (
    SELECT
        c.customer_state,
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
    ROUND(avg_delivery_days, 2) AS average_delivery_days,
    DENSE_RANK() OVER (
        ORDER BY avg_delivery_days
    ) AS fastest_state_rank
FROM state_delivery
ORDER BY fastest_state_rank;


-- 17. Slowest customer states
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY average_delivery_days DESC
LIMIT 10;


-- 18. Fastest customer states
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY average_delivery_days
LIMIT 10;