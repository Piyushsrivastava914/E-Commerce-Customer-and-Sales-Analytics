-- =============================================================================
-- Operations — Returns & Delivery Performance
-- =============================================================================

-- 6.1 Return rate by category
SELECT p.category,
       COUNT(oi.order_item_id)                                             AS items_sold,
       COUNT(r.return_id)                                                  AS items_returned,
       ROUND(100.0 * COUNT(r.return_id) / COUNT(oi.order_item_id), 2)      AS return_rate_pct
FROM order_items oi
JOIN products p     ON p.product_id = oi.product_id
LEFT JOIN returns r ON r.order_item_id = oi.order_item_id
GROUP BY p.category
ORDER BY return_rate_pct DESC;

-- 6.2 Highest-return products (minimum 40 units sold, to avoid small-sample noise)
SELECT p.product_name, p.category,
       COUNT(oi.order_item_id)                                        AS units_sold,
       COUNT(r.return_id)                                             AS returned,
       ROUND(100.0 * COUNT(r.return_id) / COUNT(oi.order_item_id), 1) AS return_rate_pct
FROM order_items oi
JOIN products p     ON p.product_id = oi.product_id
LEFT JOIN returns r ON r.order_item_id = oi.order_item_id
GROUP BY p.product_id
HAVING COUNT(oi.order_item_id) >= 40
ORDER BY return_rate_pct DESC
LIMIT 10;

-- 6.3 Delivery performance by shipping method
SELECT shipping_method,
       COUNT(*)                                                                              AS orders,
       ROUND(AVG(actual_delivery_days), 2)                                                   AS avg_delivery_days,
       ROUND(100.0 * SUM(CASE WHEN actual_delivery_days <= promised_delivery_days THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_on_time,
       ROUND(100.0 * SUM(CASE WHEN actual_delivery_days - promised_delivery_days > 3 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_significantly_delayed
FROM orders
GROUP BY shipping_method;

-- 6.4 Does a significantly delayed delivery (>3 days late) increase the odds of a return?
WITH item_delay AS (
    SELECT oi.order_item_id,
           (o.actual_delivery_days - o.promised_delivery_days > 3) AS is_delayed,
           CASE WHEN r.return_id IS NOT NULL THEN 1 ELSE 0 END      AS was_returned
    FROM order_items oi
    JOIN orders o        ON o.order_id = oi.order_id
    LEFT JOIN returns r  ON r.order_item_id = oi.order_item_id
)
SELECT CASE WHEN is_delayed THEN 'Significantly delayed' ELSE 'On-time / minor delay' END AS delivery_status,
       COUNT(*)                                                AS items,
       ROUND(100.0 * SUM(was_returned) / COUNT(*), 2)          AS return_rate_pct
FROM item_delay
GROUP BY is_delayed;
