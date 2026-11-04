-- Reverts only order_addresses; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS order_addresses_touch_updated_at ON order_addresses;
DROP TABLE order_addresses;
