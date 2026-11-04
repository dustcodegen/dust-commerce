-- Stores cart-item snapshots so titles and prices stay stable during checkout.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE line_items (
  id            TEXT PRIMARY KEY,
  cart_id       TEXT NOT NULL REFERENCES carts (id) ON DELETE CASCADE,
  variant_id    TEXT NOT NULL REFERENCES product_variants (id),
  product_id    TEXT NOT NULL REFERENCES products (id),
  -- Handle and thumbnail keep historical cart lines navigable and recognisable.
  product_handle TEXT NOT NULL,
  thumbnail      TEXT,
  title         TEXT NOT NULL,
  variant_title TEXT,
  -- Integer minor units snapshot the selected price without float errors.
  unit_amount   INTEGER NOT NULL CHECK (unit_amount >= 0),
  currency_code TEXT NOT NULL
                CHECK (length(currency_code) = 3
                       AND currency_code = lower(currency_code)),
  quantity      INTEGER NOT NULL CHECK (quantity > 0),
  metadata      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  -- Soft deletion supports removing an item while retaining audit context.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_line_items_cart ON line_items (cart_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER line_items_touch_updated_at
BEFORE UPDATE ON line_items
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
