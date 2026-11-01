-- Defines redeemable discount policy and its bounded usage window.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE promotions (
  id            TEXT PRIMARY KEY,
  code          TEXT NOT NULL,
  type          TEXT NOT NULL CHECK (type IN ('percentage', 'fixed')),
  -- Percentage values are basis points; fixed values are currency minor units.
  value         INTEGER NOT NULL CHECK (value >= 0),
  currency_code TEXT
                CHECK (currency_code IS NULL OR
                       (length(currency_code) = 3
                        AND currency_code = lower(currency_code))),
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  usage_limit   INTEGER CHECK (usage_limit IS NULL OR usage_limit > 0),
  -- Persisted count lets checkout enforce a global redemption limit atomically.
  usage_count   INTEGER NOT NULL DEFAULT 0 CHECK (usage_count >= 0),
  metadata      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  deleted_at TIMESTAMPTZ,
  -- Cross-column checks prevent internally contradictory promotion definitions.
  CHECK (type != 'percentage' OR value <= 10000),
  CHECK (type != 'fixed' OR currency_code IS NOT NULL),
  CHECK (ends_at IS NULL OR starts_at IS NULL OR ends_at > starts_at),
  CHECK (usage_limit IS NULL OR usage_count <= usage_limit)
);

CREATE UNIQUE INDEX idx_promotions_code ON promotions (code)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER promotions_touch_updated_at
BEFORE UPDATE ON promotions
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
