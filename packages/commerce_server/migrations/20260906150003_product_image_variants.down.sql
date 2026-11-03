-- Reverts only product_image_variants; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS product_image_variants_validate_product
  ON product_image_variants;
DROP FUNCTION IF EXISTS product_image_variants_validate_product();
DROP TABLE product_image_variants;
