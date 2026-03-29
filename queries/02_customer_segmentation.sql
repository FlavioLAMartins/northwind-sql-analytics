-- Objective: Segment customers into 5 groups based on total revenue
-- Method: NTILE(5) window function

CREATE VIEW vw_customer_revenue_groups AS
SELECT 
    customer_id,
    company_name,
    total,
    NTILE(5) OVER (ORDER BY total DESC) AS group_number
FROM vw_total_revenues_per_customer;