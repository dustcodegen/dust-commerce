-- Associates product gallery images with the variants that should display them.
-- An image without rows remains visible for every variant of its product.
CREATE TABLE product_image_variants (
  image_id   TEXT NOT NULL REFERENCES product_images (id) ON DELETE CASCADE,
  variant_id TEXT NOT NULL REFERENCES product_variants (id) ON DELETE CASCADE,
  -- SQLite generates the immutable UTC audit instant for each association.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  PRIMARY KEY (image_id, variant_id)
);

CREATE INDEX idx_product_image_variants_variant
ON product_image_variants (variant_id, image_id);

-- Both sides must be active children of the same product. Foreign keys alone
-- cannot express that cross-table ownership invariant in SQLite.


-- Associations are immutable pairs; callers replace them with delete/insert.

