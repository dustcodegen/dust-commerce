-- Reverts only cart_shipping_methods; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS cart_shipping_methods_touch_updated_at ON cart_shipping_methods;
DROP TABLE cart_shipping_methods;
