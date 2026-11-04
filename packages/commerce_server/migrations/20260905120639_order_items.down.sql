-- Reverts only order_items; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS order_items_touch_updated_at ON order_items;
DROP TABLE order_items;
