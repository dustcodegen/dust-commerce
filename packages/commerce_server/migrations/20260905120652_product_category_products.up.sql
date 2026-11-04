-- Links products to every public category in which they should be discovered.
CREATE TABLE product_category_products (
  product_id  TEXT NOT NULL REFERENCES products (id) ON DELETE CASCADE,
  category_id TEXT NOT NULL REFERENCES product_categories (id)
              ON DELETE CASCADE,
  -- Category-specific ordering without changing product or category identity.
  rank        INTEGER NOT NULL DEFAULT 0 CHECK (rank >= 0),
  PRIMARY KEY (product_id, category_id)
);

CREATE INDEX idx_product_category_products_category
ON product_category_products (category_id, rank, product_id);
