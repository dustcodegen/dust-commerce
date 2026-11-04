-- Stores order-time item snapshots independent of mutable catalog records.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE order_items (
  id            TEXT PRIMARY KEY,
  order_id      TEXT NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  -- IDs intentionally have no FK so deleting catalog data cannot erase history.
  variant_id    TEXT NOT NULL,
  product_id    TEXT NOT NULL,
  product_handle TEXT NOT NULL,
  thumbnail      TEXT,
  title         TEXT NOT NULL,
  variant_title TEXT,
  -- Integer minor units preserve exact historical pricing.
  unit_amount   INTEGER NOT NULL CHECK (unit_amount >= 0),
  currency_code TEXT NOT NULL
                CHECK (length(currency_code) = 3
                       AND currency_code = lower(currency_code)),
  quantity      INTEGER NOT NULL CHECK (quantity > 0),
  metadata      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP)
);

CREATE INDEX idx_order_items_order ON order_items (order_id);

-- Maintains audit timestamps if administrative correction is ever required.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER order_items_touch_updated_at
BEFORE UPDATE ON order_items
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
