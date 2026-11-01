-- Snapshots the single shipping method currently selected for a cart.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE cart_shipping_methods (
  cart_id    TEXT PRIMARY KEY REFERENCES carts (id) ON DELETE CASCADE,
  option_id  TEXT NOT NULL REFERENCES shipping_options (id),
  -- Name and amount are copied so later shipping-option edits do not change totals.
  name       TEXT NOT NULL,
  amount     INTEGER NOT NULL CHECK (amount >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP)
);

-- Upserts change the quote in place, so the database advances updated_at.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER cart_shipping_methods_touch_updated_at
BEFORE UPDATE ON cart_shipping_methods
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
