-- Reverts only product_product_options; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS product_product_options_touch_updated_at ON product_product_options;
DROP TABLE product_product_options;
