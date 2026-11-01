-- Reverts only customer_addresses; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS customer_addresses_touch_updated_at ON customer_addresses;
DROP TABLE customer_addresses;
