-- Reverts only product_options; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS product_options_touch_updated_at ON product_options;
DROP TABLE product_options;
