-- Stores guest and registered customer profiles separately from credentials.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE customers (
  id           TEXT PRIMARY KEY,
  email        TEXT,
  company_name TEXT,
  first_name   TEXT,
  last_name    TEXT,
  phone        TEXT,
  -- Distinguishes checkout-only guests from identities that can sign in.
  has_account  INTEGER NOT NULL DEFAULT 0 CHECK (has_account IN (0, 1)),
  metadata     TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  -- Soft deletion keeps orders auditable without exposing the active profile.
  deleted_at TIMESTAMPTZ
);

-- Like Medusa, one guest record and one account record may share an email.
CREATE UNIQUE INDEX idx_customers_email_account
ON customers (email, has_account)
WHERE email IS NOT NULL AND deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER customers_touch_updated_at
BEFORE UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
