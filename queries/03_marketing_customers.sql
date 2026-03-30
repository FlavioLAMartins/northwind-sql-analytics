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