-- Defines a selling market so cart prices, taxes, and allowed countries agree.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE regions (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  currency_code   TEXT NOT NULL
                  CHECK (length(currency_code) = 3
                         AND currency_code = lower(currency_code)),
  -- Basis points keep tax calculations exact without floating-point rounding.
  tax_rate        INTEGER NOT NULL CHECK (tax_rate BETWEEN 0 AND 10000),
  tax_inclusive   INTEGER NOT NULL DEFAULT 0
                  CHECK (tax_inclusive IN (0, 1)),
  -- Compact CSV matches the current domain model; application code validates it.
  countries       TEXT NOT NULL CHECK (length(countries) > 0),
  automatic_taxes INTEGER NOT NULL DEFAULT 1
                  CHECK (automatic_taxes IN (0, 1)),
  -- Extension data remains optional but must be valid JSON when present.
  metadata        TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                  (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                  (CURRENT_TIMESTAMP),
  -- Soft deletion preserves references and historical order meaning.
  deleted_at TIMESTAMPTZ
);

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER regions_touch_updated_at
BEFORE UPDATE ON regions
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
