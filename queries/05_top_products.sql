-- Objective: Identify top 10 products by total revenue
-- Metric: Net revenue (including discounts)

CREATE VIEW vw_top_10_products AS
SELECT 
    p.product_id,
    p.product_name,
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total_revenue
FROM products p
INNER JOIN order_details od 
    ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 10;