-- Reverts only the customer_groups table after membership links are removed.
DROP TRIGGER IF EXISTS customer_groups_touch_updated_at ON customer_groups;
DROP TABLE customer_groups;
