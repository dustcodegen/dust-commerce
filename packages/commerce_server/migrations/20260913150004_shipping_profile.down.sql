-- Removes fulfillment profiles after dependent product links are reverted.
DROP TRIGGER IF EXISTS shipping_profile_touch_updated_at ON shipping_profile;
DROP TABLE IF EXISTS shipping_profile;
