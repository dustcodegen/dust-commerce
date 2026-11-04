-- Removes shipping-option profile resolution and its timestamp trigger.
DROP TRIGGER IF EXISTS shipping_option_shipping_profile_touch_updated_at ON shipping_option_shipping_profile;
DROP TABLE IF EXISTS shipping_option_shipping_profile;
