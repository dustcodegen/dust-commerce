-- Reverts only the customer_group_customers membership table.
DROP TRIGGER IF EXISTS customer_group_customers_touch_updated_at ON customer_group_customers;
DROP TABLE customer_group_customers;
