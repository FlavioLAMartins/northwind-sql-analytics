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