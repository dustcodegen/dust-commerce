-- Reverts only product_categories after its product links are removed.
DROP TRIGGER IF EXISTS product_categories_touch_updated_at ON product_categories;
DROP TABLE product_categories;
