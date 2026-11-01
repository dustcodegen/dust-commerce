-- Reverts only product_option_values; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS product_option_values_touch_updated_at ON product_option_values;
DROP TABLE product_option_values;
