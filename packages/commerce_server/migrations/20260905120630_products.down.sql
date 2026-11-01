-- Reverts only the products table; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS products_touch_updated_at ON products;
DROP TABLE products;
