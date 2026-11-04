-- Registers fulfillment adapters independently from locations and options.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE fulfillment_providers (
  -- Stable provider id selects the runtime adapter and appears in Admin data.
  id         TEXT PRIMARY KEY CHECK (length(trim(id)) BETWEEN 1 AND 255),
  -- Merchant-facing name explains the adapter without exposing configuration.
  name       TEXT NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 255),
  -- Provider registration metadata stays private and valid JSON when present.
  metadata   TEXT CHECK (metadata IS NULL OR jsonb_typeof(metadata::JSONB) IS NOT NULL),
  -- PostgreSQL owns the creation instant for every provider registration.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- The trigger below owns mutation time; application code never supplies it.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Soft deletion disables selection while retaining fulfillment history.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_fulfillment_providers_name_active
ON fulfillment_providers (name, id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER fulfillment_providers_touch_updated_at
BEFORE UPDATE ON fulfillment_providers
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
