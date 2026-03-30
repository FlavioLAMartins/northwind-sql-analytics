-- Objective: Identify most sold products by quantity
-- Metric: Total quantity sold per product
-- Note: Complements revenue-based ranking

CREATE VIEW vw_top_products_by_quantity AS
SELECT 
    p.product_id,
    p.product_name,
    SUM(od.quantity) AS total_quantity
FROM products p
INNER JOIN order_details od 
    ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name;