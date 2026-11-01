-- Reverts only order_transfers; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS order_transfers_touch_updated_at ON order_transfers;
DROP TABLE order_transfers;
