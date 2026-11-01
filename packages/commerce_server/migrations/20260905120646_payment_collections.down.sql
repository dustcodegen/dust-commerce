-- Reverts only payment_collections; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS payment_collections_touch_updated_at ON payment_collections;
DROP TABLE payment_collections;
