-- =============================================================================
-- Customer Analysis — New vs. Returning, RFM Segmentation, CLV
-- =============================================================================

-- 3.1 New vs. returning customer revenue split
-- "New" = a customer's first order; "Returning" = every order after that
WITH order_seq AS (
    SELECT order_id, customer_id,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_rank
    FROM orders
)
SELECT CASE WHEN os.order_rank = 1 THEN 'New (1st order)' ELSE 'Returning (2nd+)' END AS customer_type,
       COUNT(DISTINCT os.order_id)        AS orders,
       ROUND(SUM(oi.line_net_revenue), 2) AS net_revenue,
       ROUND(100.0 * SUM(oi.line_net_revenue) / SUM(SUM(oi.line_net_revenue)) OVER (), 1) AS pct_of_revenue
FROM order_seq os
JOIN order_items oi ON oi.order_id = os.order_id
GROUP BY customer_type;

-- 3.2 Repeat-purchase rate
SELECT ROUND(100.0 * SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_purchase_rate_pct
FROM (SELECT customer_id, COUNT(*) AS order_count FROM orders GROUP BY customer_id);

-- 3.3 RFM base table: Recency (days since last order), Frequency (# orders), Monetary (net revenue)
-- Snapshot date hardcoded to the last day of data (2026-08-31); swap for CURRENT_DATE in production.
CREATE VIEW IF NOT EXISTS customer_rfm_base AS
SELECT c.customer_id,
       CAST(julianday('2026-08-31') - julianday(MAX(o.order_date)) AS INTEGER) AS recency_days,
       COUNT(DISTINCT o.order_id)         AS frequency,
       ROUND(SUM(oi.line_net_revenue), 2) AS monetary
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id  = o.order_id
GROUP BY c.customer_id;

-- 3.4 RFM quintile scores (1-5, 5 = best) — SQLite has no native NTILE-on-arbitrary-groups
-- shortcut, so this uses NTILE() window function (SQLite 3.25+ / Postgres both support it)
WITH scored AS (
    SELECT customer_id, recency_days, frequency, monetary,
           NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,   -- most recent = highest ntile
           NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
           NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
    FROM customer_rfm_base
)
SELECT
    CASE
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
        WHEN f_score >= 4                  THEN 'Loyal Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New / Promising'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Hibernating'
        ELSE 'Need Attention'
    END AS segment,
    COUNT(*)                    AS customers,
    ROUND(AVG(monetary), 2)     AS avg_clv,
    ROUND(SUM(monetary), 2)     AS total_revenue
FROM scored
GROUP BY segment
ORDER BY total_revenue DESC;

-- 3.5 Overall average CLV (historical, net-revenue based)
SELECT ROUND(AVG(monetary), 2) AS avg_clv FROM customer_rfm_base;
