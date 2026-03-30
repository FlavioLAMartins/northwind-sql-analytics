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