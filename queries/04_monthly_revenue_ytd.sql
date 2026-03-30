-- Objective: Analyze monthly revenue performance with month-over-month change and year-to-date revenue
-- Metrics: monthly revenue, previous month revenue, monthly difference, monthly percentage change, and YTD revenue

CREATE OR REPLACE VIEW vw_monthly_revenue_ytd AS
WITH monthly_revenue AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS year,
        EXTRACT(MONTH FROM o.order_date) AS month,
        SUM(od.quantity * od.unit_price * (1 - od.discount)) AS monthly_revenue
    FROM orders o
    INNER JOIN order_details od
        ON o.order_id = od.order_id
    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),
monthly_revenue_ytd AS (
    SELECT
        year,
        month,
        monthly_revenue,
        SUM(monthly_revenue) OVER (
            PARTITION BY year
            ORDER BY month
        ) AS revenue_ytd
    FROM monthly_revenue
),
monthly_revenue_with_lag AS (
    SELECT
        year,
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            PARTITION BY year
            ORDER BY month
        ) AS previous_month_revenue,
        revenue_ytd
    FROM monthly_revenue_ytd
)
SELECT
    year,
    month,
    monthly_revenue,
    previous_month_revenue,
    monthly_revenue - previous_month_revenue AS monthly_difference,
    revenue_ytd,
    (monthly_revenue - previous_month_revenue) / NULLIF(previous_month_revenue, 0) AS monthly_percentage_change
FROM monthly_revenue_with_lag;