-- Reverts only product_product_option_values; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS product_product_option_values_touch_updated_at ON product_product_option_values;
DROP TRIGGER IF EXISTS product_product_option_values_validate_option
  ON product_product_option_values;
DROP FUNCTION IF EXISTS product_product_option_values_validate_option();
DROP TABLE product_product_option_values;
