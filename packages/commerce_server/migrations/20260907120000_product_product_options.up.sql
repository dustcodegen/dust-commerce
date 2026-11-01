-- Links reusable options to products without copying the option definition.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_product_options (
  id                TEXT PRIMARY KEY,
  product_id        TEXT NOT NULL REFERENCES products (id) ON DELETE CASCADE,
  product_option_id TEXT NOT NULL
                    REFERENCES product_options (id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  -- Soft deletion detaches an option without erasing historical identity.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_product_product_options_active_pair
ON product_product_options (product_id, product_option_id)
WHERE deleted_at IS NULL;
CREATE INDEX idx_product_product_options_option
ON product_product_options (product_option_id, product_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_product_options_touch_updated_at
BEFORE UPDATE ON product_product_options
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
