-- Declares which payment providers a selling region can offer at checkout.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE region_payment_providers (
  -- Provider identifiers are public API values such as "manual".
  provider_id TEXT NOT NULL CHECK (length(trim(provider_id)) > 0),
  -- A provider is configured independently for each currency and territory.
  region_id   TEXT NOT NULL REFERENCES regions (id) ON DELETE CASCADE,
  -- Disabled rows preserve merchant configuration without advertising it.
  enabled     INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1)),
  created_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  PRIMARY KEY (region_id, provider_id)
);

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER region_payment_providers_touch_updated_at
BEFORE UPDATE ON region_payment_providers
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
