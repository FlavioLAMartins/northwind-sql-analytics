-- Objective: Calculate total revenue per customer
-- Metric: Net revenue (including discounts)

CREATE OR REPLACE VIEW vw_total_revenues_per_customer AS
SELECT 
    c.customer_id,
    c.company_name,
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
INNER JOIN order_details od 
    ON o.order_id = od.order_id
GROUP BY 
    c.customer_id, 
    c.company_name;

-- Objective: Segment customers into 5 groups based on total revenue
-- Method: NTILE(5) window function

CREATE OR REPLACE VIEW vw_customer_revenue_groups AS
SELECT 
    customer_id,
    company_name,
    total,
    NTILE(5) OVER (ORDER BY total DESC) AS group_number
FROM vw_total_revenues_per_customer;

-- Objective: Identify customers for targeted marketing campaigns
-- Criteria: Customers in lower revenue segments (groups 3, 4, and 5)
-- Source: Customer segmentation based on NTILE(5)

CREATE OR REPLACE VIEW vw_marketing_customers AS
SELECT 
    customer_id,
    company_name,
    total, 
    group_number
FROM vw_customer_revenue_groups
WHERE group_number IN (3, 4, 5);

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

-- Objective: Calculate total revenue per product
-- Metric: Net revenue (including discounts)

CREATE OR REPLACE VIEW vw_top_products_by_revenue AS
SELECT 
    p.product_id,
    p.product_name,
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total_revenue
FROM products p
INNER JOIN order_details od 
    ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name;

-- Objective: Identify UK customers with high total payments
-- Criteria: Total payments greater than 1000 (net revenue)
-- Filter: Country = UK

CREATE OR REPLACE VIEW vw_uk_customers_with_payments_greater_than_1000 AS
SELECT 
    c.customer_id,
    c.company_name,
    c.country,
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS payments
FROM customers c 
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
INNER JOIN order_details od 
    ON o.order_id = od.order_id
WHERE LOWER(c.country) = 'uk'
GROUP BY 
    c.customer_id,
    c.company_name,
    c.country
HAVING SUM((od.unit_price * od.quantity) * (1 - od.discount)) > 1000;


-- Objective: Calculate total revenue by shipping country
-- Metric: Net revenue grouped by order destination country

CREATE OR REPLACE VIEW vw_revenue_by_country AS
SELECT 
    o.ship_country,
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total_revenue
FROM orders o
INNER JOIN order_details od 
    ON o.order_id = od.order_id
GROUP BY o.ship_country;


-- Objective: Identify most sold products by quantity
-- Metric: Total quantity sold per product
-- Note: Complements revenue-based ranking

CREATE OR REPLACE VIEW vw_top_products_by_quantity AS
SELECT 
    p.product_id,
    p.product_name,
    SUM(od.quantity) AS total_quantity
FROM products p
INNER JOIN order_details od 
    ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name;