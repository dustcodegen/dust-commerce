-- Stores shipping and billing snapshots as they were when the order was placed.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE order_addresses (
  order_id     TEXT NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  -- Composite key permits at most one address of each role per order.
  kind         TEXT NOT NULL CHECK (kind IN ('shipping', 'billing')),
  first_name   TEXT NOT NULL,
  last_name    TEXT NOT NULL,
  -- Optional organization is distinct from the secondary street line.
  company      TEXT,
  line1        TEXT NOT NULL,
  line2        TEXT,
  city         TEXT NOT NULL,
  province     TEXT,
  postal_code  TEXT NOT NULL,
  -- Lowercase ISO 3166-1 alpha-2 code keeps region comparisons deterministic.
  country_code TEXT NOT NULL
               CHECK (length(country_code) = 2
                      AND country_code = lower(country_code)),
  phone        TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  PRIMARY KEY (order_id, kind)
);

-- Composite keys identify the exact address whose timestamp must advance.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER order_addresses_touch_updated_at
BEFORE UPDATE ON order_addresses
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
