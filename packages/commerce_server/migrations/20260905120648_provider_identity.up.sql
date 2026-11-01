-- Email/password is one provider. Its provider_metadata holds a self-describing
-- Argon2id PHC string; the password itself is never stored.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE provider_identity (
  id                TEXT PRIMARY KEY,
  -- Provider-scoped login identifier; emailpass stores normalized email here.
  entity_id         TEXT NOT NULL CHECK (length(entity_id) > 0),
  provider          TEXT NOT NULL CHECK (length(provider) > 0),
  auth_identity_id  TEXT NOT NULL REFERENCES auth_identity (id)
                    ON UPDATE CASCADE ON DELETE CASCADE,
  -- Untrusted provider profile data is kept apart from trusted app metadata.
  user_metadata     TEXT,
  provider_metadata TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_provider_identity_auth ON provider_identity (auth_identity_id)
WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_provider_identity_entity_provider
ON provider_identity (entity_id, provider)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER provider_identity_touch_updated_at
BEFORE UPDATE ON provider_identity
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
