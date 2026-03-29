-- Objective: Calculate total revenue per customer
-- Metric: Net revenue (including discounts)

CREATE VIEW vw_total_revenues_per_customer AS
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