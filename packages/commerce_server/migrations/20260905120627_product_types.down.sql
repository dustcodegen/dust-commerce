-- Reverts only product_types after dependent product rows are removed.
DROP TRIGGER IF EXISTS product_types_touch_updated_at ON product_types;
DROP TABLE product_types;
