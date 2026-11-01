-- Defines a region-specific delivery choice and its exact checkout charge.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE shipping_options (
  id            TEXT PRIMARY KEY,
  region_id     TEXT NOT NULL REFERENCES regions (id) ON DELETE CASCADE,
  name          TEXT NOT NULL CHECK (length(name) > 0),
  -- Integer minor units avoid floating-point money errors.
  amount        INTEGER NOT NULL CHECK (amount >= 0),
  currency_code TEXT NOT NULL
                CHECK (length(currency_code) = 3
                       AND currency_code = lower(currency_code)),
  metadata      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  -- Soft deletion hides the option without invalidating existing orders.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_shipping_options_region ON shipping_options (region_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER shipping_options_touch_updated_at
BEFORE UPDATE ON shipping_options
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
