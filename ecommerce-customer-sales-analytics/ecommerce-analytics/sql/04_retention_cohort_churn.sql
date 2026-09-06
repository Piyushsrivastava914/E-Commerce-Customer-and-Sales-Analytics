-- =============================================================================
-- Retention — Monthly Cohort Analysis & Churn
-- =============================================================================

-- 4.1 Monthly cohort retention matrix
-- Postgres: strftime('%Y-%m', d) -> TO_CHAR(d,'YYYY-MM'); the year/month arithmetic below
-- becomes (EXTRACT(YEAR FROM order_date) - EXTRACT(YEAR FROM cohort_date))*12 + ...
WITH first_order AS (
    SELECT customer_id, MIN(order_date) AS cohort_date
    FROM orders
    GROUP BY customer_id
),
order_months AS (
    SELECT o.customer_id,
           strftime('%Y-%m', f.cohort_date) AS cohort_month,
           (CAST(strftime('%Y', o.order_date) AS INT) - CAST(strftime('%Y', f.cohort_date) AS INT)) * 12
             + (CAST(strftime('%m', o.order_date) AS INT) - CAST(strftime('%m', f.cohort_date) AS INT)) AS month_number
    FROM orders o
    JOIN first_order f ON f.customer_id = o.customer_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS num_customers
    FROM order_months
    WHERE month_number = 0
    GROUP BY cohort_month
)
SELECT om.cohort_month,
       om.month_number,
       COUNT(DISTINCT om.customer_id)                                        AS active_customers,
       cs.num_customers                                                       AS cohort_size,
       ROUND(100.0 * COUNT(DISTINCT om.customer_id) / cs.num_customers, 1)   AS retention_pct
FROM order_months om
JOIN cohort_size cs ON cs.cohort_month = om.cohort_month
GROUP BY om.cohort_month, om.month_number
ORDER BY om.cohort_month, om.month_number;

-- 4.2 Average retention curve across "mature" cohorts (acquired by Dec 2025, so every cohort
-- below has at least 8 months of possible follow-up data as of the Aug-2026 snapshot)
WITH first_order AS (
    SELECT customer_id, MIN(order_date) AS cohort_date FROM orders GROUP BY customer_id
),
order_months AS (
    SELECT o.customer_id,
           strftime('%Y-%m', f.cohort_date) AS cohort_month,
           (CAST(strftime('%Y', o.order_date) AS INT) - CAST(strftime('%Y', f.cohort_date) AS INT)) * 12
             + (CAST(strftime('%m', o.order_date) AS INT) - CAST(strftime('%m', f.cohort_date) AS INT)) AS month_number
    FROM orders o JOIN first_order f ON f.customer_id = o.customer_id
    WHERE f.cohort_date <= '2025-12-31'
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS num_customers
    FROM order_months WHERE month_number = 0 GROUP BY cohort_month
)
SELECT om.month_number,
       ROUND(AVG(100.0 * cnt.active / cs.num_customers), 1) AS avg_retention_pct
FROM (SELECT cohort_month, month_number, COUNT(DISTINCT customer_id) AS active
      FROM order_months GROUP BY cohort_month, month_number) cnt
JOIN order_months om ON om.cohort_month = cnt.cohort_month AND om.month_number = cnt.month_number
JOIN cohort_size cs ON cs.cohort_month = cnt.cohort_month
GROUP BY om.month_number
ORDER BY om.month_number
LIMIT 7;

-- 4.3 Churn rate: no purchase in the trailing 180 days as of the data snapshot (2026-08-31)
SELECT ROUND(100.0 * SUM(CASE WHEN julianday('2026-08-31') - julianday(last_order) > 180 THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS churn_rate_180d_pct
FROM (SELECT customer_id, MAX(order_date) AS last_order FROM orders GROUP BY customer_id);
