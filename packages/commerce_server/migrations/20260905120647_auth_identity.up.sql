-- Medusa separates the actor from any provider used to authenticate it.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE auth_identity (
  id           TEXT PRIMARY KEY,
  -- Trusted application links (currently customer_id); clients cannot write it.
  app_metadata TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_auth_identity_deleted_at ON auth_identity (deleted_at)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER auth_identity_touch_updated_at
BEFORE UPDATE ON auth_identity
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
