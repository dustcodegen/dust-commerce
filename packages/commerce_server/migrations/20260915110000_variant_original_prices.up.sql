-- Stores the crossed-out customer price that proves a variant is on sale.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE variant_original_prices (
  variant_id    TEXT NOT NULL REFERENCES product_variants (id)
                ON DELETE CASCADE,
  currency_code TEXT NOT NULL
                CHECK (length(currency_code) = 3
                       AND currency_code = lower(currency_code)),
  -- Original minor-unit price shown only when above the active selling price.
  amount        INTEGER NOT NULL CHECK (amount >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  -- One original price per variant and storefront currency.
  PRIMARY KEY (variant_id, currency_code)
);

-- Composite keys identify the exact original price whose timestamp advances.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER variant_original_prices_touch_updated_at
BEFORE UPDATE ON variant_original_prices
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
