-- Assigns one exact minor-unit price to a variant in each currency.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE variant_prices (
  variant_id    TEXT NOT NULL REFERENCES product_variants (id)
                ON DELETE CASCADE,
  currency_code TEXT NOT NULL
                CHECK (length(currency_code) = 3
                       AND currency_code = lower(currency_code)),
  -- Integer minor units avoid floating-point money errors.
  amount        INTEGER NOT NULL CHECK (amount >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  -- A variant cannot have two competing prices for the same currency.
  PRIMARY KEY (variant_id, currency_code)
);

-- Composite keys identify the exact price whose timestamp must advance.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER variant_prices_touch_updated_at
BEFORE UPDATE ON variant_prices
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
