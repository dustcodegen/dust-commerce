-- Reverts only product_variants; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS product_variants_touch_updated_at ON product_variants;
DROP TABLE product_variants;
