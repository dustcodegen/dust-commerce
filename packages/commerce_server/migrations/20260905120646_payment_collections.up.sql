-- Tracks money collection for an order without storing provider card secrets.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE payment_collections (
  id            TEXT PRIMARY KEY,
  -- One order has one collection; retries must reuse it, never double charge.
  order_id      TEXT NOT NULL UNIQUE REFERENCES orders (id) ON DELETE CASCADE,
  -- Identifies the external adapter; provider-specific state belongs in metadata.
  provider      TEXT NOT NULL CHECK (length(provider) > 0),
  -- Integer minor units avoid floating-point money errors.
  amount        INTEGER NOT NULL CHECK (amount >= 0),
  currency_code TEXT NOT NULL
                CHECK (length(currency_code) = 3
                       AND currency_code = lower(currency_code)),
  status        TEXT NOT NULL
                CHECK (status IN ('pending', 'authorized', 'captured',
                                  'canceled', 'failed')),
  metadata      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  -- Set only when funds actually move; status alone is not an event timestamp.
  captured_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_payment_collections_order ON payment_collections (order_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER payment_collections_touch_updated_at
BEFORE UPDATE ON payment_collections
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
