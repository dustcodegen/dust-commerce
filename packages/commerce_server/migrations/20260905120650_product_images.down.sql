-- Reverts only product_images; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS product_images_touch_updated_at ON product_images;
DROP TABLE product_images;
