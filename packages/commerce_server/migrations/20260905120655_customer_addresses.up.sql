-- Stores reusable customer destinations separately from immutable order snapshots.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE customer_addresses (
  id                  TEXT PRIMARY KEY,
  customer_id         TEXT NOT NULL REFERENCES customers (id)
                      ON DELETE CASCADE,
  -- Merchant label distinguishes multiple reusable destinations.
  address_name        TEXT CHECK (address_name IS NULL
                                  OR length(trim(address_name)) > 0),
  first_name          TEXT CHECK (first_name IS NULL
                                  OR length(trim(first_name)) > 0),
  last_name           TEXT CHECK (last_name IS NULL
                                  OR length(trim(last_name)) > 0),
  company             TEXT CHECK (company IS NULL
                                  OR length(trim(company)) > 0),
  phone               TEXT CHECK (phone IS NULL OR length(trim(phone)) > 0),
  address_1           TEXT NOT NULL CHECK (length(trim(address_1)) > 0),
  address_2           TEXT CHECK (address_2 IS NULL
                                  OR length(trim(address_2)) > 0),
  city                TEXT CHECK (city IS NULL OR length(trim(city)) > 0),
  province            TEXT CHECK (province IS NULL
                                  OR length(trim(province)) > 0),
  postal_code         TEXT CHECK (postal_code IS NULL
                                  OR length(trim(postal_code)) > 0),
  -- Lowercase ISO code makes region and country comparisons deterministic.
  country_code        TEXT NOT NULL
                      CHECK (length(country_code) = 2
                             AND country_code = lower(country_code)),
  -- Each role has at most one active default per customer.
  is_default_shipping INTEGER NOT NULL DEFAULT 0
                      CHECK (is_default_shipping IN (0, 1)),
  is_default_billing  INTEGER NOT NULL DEFAULT 0
                      CHECK (is_default_billing IN (0, 1)),
  metadata            TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                      (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                      (CURRENT_TIMESTAMP),
  -- Soft deletion preserves audit history without returning stale destinations.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_customer_addresses_customer
ON customer_addresses (customer_id, created_at, id)
WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_customer_addresses_default_shipping
ON customer_addresses (customer_id)
WHERE deleted_at IS NULL AND is_default_shipping = 1;
CREATE UNIQUE INDEX idx_customer_addresses_default_billing
ON customer_addresses (customer_id)
WHERE deleted_at IS NULL AND is_default_billing = 1;

-- Selecting a new default atomically clears the previous active destination.
CREATE OR REPLACE FUNCTION customer_addresses_normalize_defaults()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
  IF NEW.deleted_at IS NULL AND NEW.is_default_shipping = 1 THEN
    UPDATE customer_addresses
    SET is_default_shipping = 0
    WHERE customer_id = NEW.customer_id
      AND id <> NEW.id
      AND deleted_at IS NULL
      AND is_default_shipping = 1;
  END IF;
  IF NEW.deleted_at IS NULL AND NEW.is_default_billing = 1 THEN
    UPDATE customer_addresses
    SET is_default_billing = 0
    WHERE customer_id = NEW.customer_id
      AND id <> NEW.id
      AND deleted_at IS NULL
      AND is_default_billing = 1;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER customer_addresses_normalize_defaults
BEFORE INSERT OR UPDATE OF customer_id, is_default_shipping, is_default_billing,
  deleted_at ON customer_addresses
FOR EACH ROW
EXECUTE FUNCTION customer_addresses_normalize_defaults();





-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER customer_addresses_touch_updated_at
BEFORE UPDATE ON customer_addresses
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
