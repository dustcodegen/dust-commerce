-- Reverts only shipping_option_price_rules; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS shipping_option_price_rules_touch_updated_at ON shipping_option_price_rules;
DROP TABLE shipping_option_price_rules;
