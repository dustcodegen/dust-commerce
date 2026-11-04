-- Snapshots the single promotion currently applied to a cart.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE cart_promotions (
  cart_id       TEXT PRIMARY KEY REFERENCES carts (id) ON DELETE CASCADE,
  promotion_id  TEXT NOT NULL REFERENCES promotions (id),
  -- Customer-facing policy fields are frozen with the calculated amount.
  code          TEXT NOT NULL,
  type          TEXT NOT NULL CHECK (type IN ('percentage', 'fixed')),
  -- Percentage values are basis points; fixed values are currency minor units.
  value         INTEGER NOT NULL CHECK (value >= 0),
  currency_code TEXT
                CHECK (currency_code IS NULL OR
                       (length(currency_code) = 3
                        AND currency_code = lower(currency_code))),
  amount        INTEGER NOT NULL CHECK (amount >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  -- A percentage is currency-free; a fixed value must name its currency.
  CHECK ((type = 'percentage' AND currency_code IS NULL) OR
         (type = 'fixed' AND currency_code IS NOT NULL)),
  CHECK (type != 'percentage' OR value <= 10000)
);

-- Upserts change the applied discount in place, so updated_at must advance.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER cart_promotions_touch_updated_at
BEFORE UPDATE ON cart_promotions
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
