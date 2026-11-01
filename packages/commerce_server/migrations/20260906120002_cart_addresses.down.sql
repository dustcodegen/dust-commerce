-- Reverts only checkout destinations; the cart itself remains independently owned.
DROP TRIGGER IF EXISTS cart_addresses_touch_updated_at ON cart_addresses;
DROP TABLE cart_addresses;
