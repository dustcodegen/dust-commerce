-- Removes product fulfillment links and their database-owned maintenance.
DROP TRIGGER IF EXISTS product_shipping_profile_attach_product_after_insert
  ON products;
DROP FUNCTION IF EXISTS product_shipping_profile_attach_default();
DROP TRIGGER IF EXISTS product_shipping_profile_touch_updated_at ON product_shipping_profile;
DROP TABLE IF EXISTS product_shipping_profile;
