-- Associates product gallery images with the variants that should display them.
-- An image without rows remains visible for every variant of its product.
CREATE TABLE product_image_variants (
  image_id   TEXT NOT NULL REFERENCES product_images (id) ON DELETE CASCADE,
  variant_id TEXT NOT NULL REFERENCES product_variants (id) ON DELETE CASCADE,
  -- PostgreSQL generates the immutable UTC audit instant for each association.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  PRIMARY KEY (image_id, variant_id)
);

CREATE INDEX idx_product_image_variants_variant
ON product_image_variants (variant_id, image_id);

-- Both sides must be active children of the same product. Foreign keys alone
-- cannot express that cross-table ownership invariant with foreign keys alone.
CREATE OR REPLACE FUNCTION product_image_variants_validate_product()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
  image_product_id TEXT;
  variant_product_id TEXT;
BEGIN
  SELECT product_id INTO image_product_id
  FROM product_images WHERE id = NEW.image_id;
  SELECT product_id INTO variant_product_id
  FROM product_variants WHERE id = NEW.variant_id;
  IF image_product_id IS NULL OR variant_product_id IS NULL
     OR image_product_id <> variant_product_id THEN
    RAISE EXCEPTION 'product image and variant must share a product';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER product_image_variants_validate_product
BEFORE INSERT OR UPDATE ON product_image_variants
FOR EACH ROW
EXECUTE FUNCTION product_image_variants_validate_product();


-- Associations are immutable pairs; callers replace them with delete/insert.

