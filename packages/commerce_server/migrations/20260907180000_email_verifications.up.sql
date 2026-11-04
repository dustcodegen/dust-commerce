-- Stores the current single-use email capability for one authentication identity.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE email_verifications (
  auth_identity_id TEXT PRIMARY KEY REFERENCES auth_identity (id)
                   ON UPDATE CASCADE ON DELETE CASCADE,
  -- Only a SHA-256 fingerprint is retained; a database read cannot verify email.
  token_hash       TEXT UNIQUE CHECK
                   (token_hash IS NULL OR length(token_hash) = 64),
  -- Explicit expiry bounds an emailed capability independently of cleanup.
  expires_at TIMESTAMPTZ NOT NULL,
  -- A value proves completion; NULL means sign-in must remain unavailable.
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                   (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                   (CURRENT_TIMESTAMP),
  CHECK (verified_at IS NOT NULL OR token_hash IS NOT NULL)
);

CREATE INDEX idx_email_verifications_expiry
ON email_verifications (expires_at)
WHERE verified_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER email_verifications_touch_updated_at
BEFORE UPDATE ON email_verifications
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
