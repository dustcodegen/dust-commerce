-- Reverts only product_tags after its product links are removed.
DROP TRIGGER IF EXISTS product_tags_touch_updated_at ON product_tags;
DROP TABLE product_tags;
