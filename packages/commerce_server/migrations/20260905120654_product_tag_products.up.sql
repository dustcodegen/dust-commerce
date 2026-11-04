-- Links a product to each public tag used for filtering and discovery.
CREATE TABLE product_tag_products (
  product_id TEXT NOT NULL REFERENCES products (id) ON DELETE CASCADE,
  tag_id     TEXT NOT NULL REFERENCES product_tags (id) ON DELETE CASCADE,
  PRIMARY KEY (product_id, tag_id)
);

CREATE INDEX idx_product_tag_products_tag
ON product_tag_products (tag_id, product_id);
