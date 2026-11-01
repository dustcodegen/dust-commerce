-- Reverts only product_collections after dependent product rows are removed.
DROP TRIGGER IF EXISTS product_collections_touch_updated_at ON product_collections;
DROP TABLE product_collections;
