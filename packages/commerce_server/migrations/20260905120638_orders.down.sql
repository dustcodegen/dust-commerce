-- Reverts only the orders table; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS orders_touch_updated_at ON orders;
DROP TABLE orders;
