-- Retains checkout destinations on the mutable cart across reloads and retries.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE cart_addresses (
  cart_id      TEXT NOT NULL REFERENCES carts (id) ON DELETE CASCADE,
  -- One shipping row and at most one separate billing row belong to a cart.
  kind         TEXT NOT NULL CHECK (kind IN ('shipping', 'billing')),
  first_name   TEXT NOT NULL,
  last_name    TEXT NOT NULL,
  -- Organization stays distinct from apartment, suite, or secondary street.
  company      TEXT,
  line1        TEXT NOT NULL,
  line2        TEXT,
  city         TEXT NOT NULL,
  province     TEXT,
  postal_code  TEXT NOT NULL,
  -- Lowercase ISO 3166-1 alpha-2 code validated against the cart region.
  country_code TEXT NOT NULL CHECK (
    length(country_code) = 2 AND country_code = lower(country_code)
  ),
  phone        TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  PRIMARY KEY (cart_id, kind)
);

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER cart_addresses_touch_updated_at
BEFORE UPDATE ON cart_addresses
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
