-- Reverts only shipping_options; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS shipping_options_touch_updated_at ON shipping_options;
DROP TABLE shipping_options;
