-- =============================================================================
-- Marketing — Discount Impact & Acquisition Channel Performance
-- =============================================================================

-- 5.1 Discount band vs. revenue and profit margin (the headline finding)
WITH item_disc AS (
    SELECT oi.*, o.discount_pct,
        CASE WHEN o.discount_pct = 0        THEN '0% (full price)'
             WHEN o.discount_pct <= 0.10    THEN '1-10%'
             WHEN o.discount_pct <= 0.25    THEN '11-25%'
             ELSE '26-40%' END AS discount_band
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
)
SELECT discount_band,
       COUNT(*)                                                     AS line_items,
       ROUND(SUM(line_net_revenue), 2)                              AS net_revenue,
       ROUND(100.0 * SUM(line_profit) / SUM(line_net_revenue), 2)   AS avg_margin_pct
FROM item_disc
GROUP BY discount_band
ORDER BY MIN(discount_pct);

-- 5.2 Acquisition channel performance: customers, avg orders, avg LTV, one-and-done rate
-- NOTE: joining orders -> order_items multiplies rows per order, so counts of orders/customers
-- must use COUNT(DISTINCT ...) — a easy-to-miss bug that silently inflates "avg orders" if skipped.
WITH cust_value AS (
    SELECT c.customer_id, c.acquisition_channel,
           COUNT(DISTINCT o.order_id)         AS n_orders,
           SUM(oi.line_net_revenue)           AS ltv
    FROM customers c
    JOIN orders o       ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id  = o.order_id
    GROUP BY c.customer_id
)
SELECT acquisition_channel,
       COUNT(*)                                                              AS customers,
       ROUND(AVG(n_orders), 2)                                               AS avg_orders_per_customer,
       ROUND(AVG(ltv), 2)                                                    AS avg_ltv,
       ROUND(100.0 * SUM(CASE WHEN n_orders = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_one_and_done
FROM cust_value
GROUP BY acquisition_channel
ORDER BY avg_ltv DESC;

-- 5.3 Customer acquisition cost (CAC) by channel — spend / new customers acquired that month
-- Direct has no marketing_spend rows (it's unpaid), so it's excluded here by the join.
WITH new_custs AS (
    SELECT acquisition_channel,
           strftime('%Y-%m-01', first_order_date) AS month,
           COUNT(*) AS new_customers
    FROM customers
    GROUP BY acquisition_channel, month
)
SELECT ms.channel,
       ROUND(SUM(ms.spend), 2)                                    AS total_spend,
       SUM(nc.new_customers)                                       AS new_customers,
       ROUND(SUM(ms.spend) / NULLIF(SUM(nc.new_customers), 0), 2)  AS cac
FROM marketing_spend ms
JOIN new_custs nc ON nc.acquisition_channel = ms.channel AND nc.month = ms.month
GROUP BY ms.channel
ORDER BY cac;
