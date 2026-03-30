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
