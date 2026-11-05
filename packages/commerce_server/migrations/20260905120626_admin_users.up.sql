-- Stores people allowed to operate the merchant-only admin API.
-- Authentication credentials remain in provider_identity, not this profile.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.

-- Shared PostgreSQL compatibility helpers keep the existing query contract
-- stable across the PostgreSQL-backed runtime and generated query contract.
CREATE OR REPLACE FUNCTION strftime(format TEXT, base TEXT, modifier TEXT DEFAULT NULL)
RETURNS TIMESTAMPTZ
LANGUAGE SQL
STABLE
AS $$
  SELECT CASE
    WHEN modifier IS NULL THEN CURRENT_TIMESTAMP
    WHEN modifier LIKE '-% minutes' THEN CURRENT_TIMESTAMP - (replace(modifier, ' minutes', '')::INTEGER * INTERVAL '1 minute')
    WHEN modifier LIKE '-% hours' THEN CURRENT_TIMESTAMP - (replace(modifier, ' hours', '')::INTEGER * INTERVAL '1 hour')
    WHEN modifier LIKE '-% days' THEN CURRENT_TIMESTAMP - (replace(modifier, ' days', '')::INTEGER * INTERVAL '1 day')
    ELSE CURRENT_TIMESTAMP
  END
$$;

CREATE OR REPLACE FUNCTION instr(haystack TEXT, needle TEXT)
RETURNS INTEGER
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT strpos(haystack, needle) $$;

CREATE OR REPLACE FUNCTION dust_touch_updated_at()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
  IF NEW.updated_at = OLD.updated_at THEN
    NEW.updated_at = CURRENT_TIMESTAMP;
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION dust_json_value(value TEXT)
RETURNS JSONB
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT value::JSONB $$;

CREATE OR REPLACE FUNCTION dust_json_value(value JSONB)
RETURNS JSONB
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT value $$;

CREATE OR REPLACE FUNCTION dust_json_value(value JSON)
RETURNS JSONB
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT value::JSONB $$;

CREATE OR REPLACE FUNCTION json_extract(value TEXT, path TEXT)
RETURNS TEXT
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT CASE WHEN path = '$' THEN value ELSE value::JSONB ->> trim(path, '$.') END $$;

CREATE OR REPLACE FUNCTION json_extract(value JSONB, path TEXT)
RETURNS TEXT
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT CASE WHEN path = '$' THEN value::TEXT ELSE value ->> trim(path, '$.') END $$;

CREATE OR REPLACE FUNCTION json_type(value TEXT, path TEXT)
RETURNS TEXT
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT jsonb_typeof(value::JSONB #> string_to_array(trim(path, '$.'), '.')) $$;

CREATE OR REPLACE FUNCTION json_set(value TEXT, path TEXT, replacement TEXT)
RETURNS TEXT
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT jsonb_set(value::JSONB, string_to_array(trim(path, '$.'), '.'), to_jsonb(replacement), TRUE)::TEXT $$;

CREATE OR REPLACE FUNCTION json_remove(value TEXT, path TEXT)
RETURNS TEXT
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT (value::JSONB #- string_to_array(trim(path, '$.'), '.'))::TEXT $$;

CREATE OR REPLACE FUNCTION json_array_length(value TEXT)
RETURNS INTEGER
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT jsonb_array_length(value::JSONB) $$;

CREATE OR REPLACE FUNCTION json_each(value TEXT)
RETURNS TABLE(key TEXT, value TEXT)
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT key, value FROM jsonb_each_text(value::JSONB) $$;

CREATE OR REPLACE FUNCTION iif(condition BOOLEAN, when_true TEXT, when_false TEXT)
RETURNS TEXT
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT CASE WHEN condition THEN when_true ELSE when_false END $$;

CREATE OR REPLACE FUNCTION iif(condition BOOLEAN, when_true INTEGER, when_false INTEGER)
RETURNS INTEGER
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT CASE WHEN condition THEN when_true ELSE when_false END $$;

CREATE OR REPLACE FUNCTION iif(condition BOOLEAN, when_true JSONB, when_false JSONB)
RETURNS JSONB
LANGUAGE SQL
IMMUTABLE
AS $$ SELECT CASE WHEN condition THEN when_true ELSE when_false END $$;

CREATE TABLE admin_users (
  -- Opaque public identifier; authorization resolves it through auth_identity.
  id         TEXT PRIMARY KEY,
  -- Normalized sign-in address and operational contact identifier.
  email      TEXT NOT NULL
             CHECK (length(email) BETWEEN 3 AND 254),
  -- Optional display names must never be used as authorization facts.
  first_name TEXT CHECK (first_name IS NULL OR length(first_name) BETWEEN 1 AND 100),
  -- Optional family name is display data, never an authorization fact.
  last_name  TEXT CHECK (last_name IS NULL OR length(last_name) BETWEEN 1 AND 100),
  -- Disabled users retain audit relationships but cannot authenticate.
  status     TEXT NOT NULL DEFAULT 'active'
             CHECK (status IN ('active', 'disabled')),
  -- PostgreSQL generates the audit creation instant in UTC.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Audit mutation instant maintained by the trigger below.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Soft deletion preserves the actor named by future audit records.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_admin_users_email_active
ON admin_users (email)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER admin_users_touch_updated_at
BEFORE UPDATE ON admin_users
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
