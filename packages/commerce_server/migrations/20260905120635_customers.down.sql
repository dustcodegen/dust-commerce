-- Reverts only the customers table; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS customers_touch_updated_at ON customers;
DROP TABLE customers;
