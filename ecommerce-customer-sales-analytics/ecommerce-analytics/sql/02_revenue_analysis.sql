-- =============================================================================
-- Revenue Analysis
-- =============================================================================

-- 2.1 Monthly revenue trend
-- Postgres: replace strftime('%Y-%m', order_date) with TO_CHAR(order_date, 'YYYY-MM')
SELECT strftime('%Y-%m', o.order_date) AS month,
       COUNT(DISTINCT o.order_id)       AS orders,
       ROUND(SUM(oi.line_net_revenue),2) AS net_revenue,
       ROUND(SUM(oi.line_profit),2)      AS profit
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY 1
ORDER BY 1;

-- 2.2 Weekly revenue trend (ISO week)
-- Postgres: replace strftime('%Y-W%W', order_date) with TO_CHAR(order_date, 'IYYY-"W"IW')
SELECT strftime('%Y-W%W', o.order_date) AS iso_week,
       ROUND(SUM(oi.line_net_revenue),2) AS net_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY 1
ORDER BY 1;

-- 2.3 Revenue and margin by category
SELECT p.category,
       ROUND(SUM(oi.line_net_revenue),2)                          AS net_revenue,
       ROUND(SUM(oi.line_profit),2)                                AS profit,
       ROUND(100.0 * SUM(oi.line_profit) / SUM(oi.line_net_revenue), 2) AS margin_pct
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY net_revenue DESC;

-- 2.4 Average Order Value (AOV) and overall profit margin
SELECT ROUND(SUM(oi.line_net_revenue) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS aov,
       ROUND(100.0 * SUM(oi.line_profit) / SUM(oi.line_net_revenue), 2)      AS overall_margin_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id;

-- 2.5 Top 10 products by net revenue
SELECT p.product_name, p.category,
       ROUND(SUM(oi.line_net_revenue),2) AS net_revenue,
       SUM(oi.quantity)                  AS units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY net_revenue DESC
LIMIT 10;
