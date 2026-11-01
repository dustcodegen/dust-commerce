-- Defines fulfillment behavior shared by products and delivery options.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE shipping_profile (
  id         TEXT PRIMARY KEY,
  -- Merchant-facing name identifies the profile in Admin selection controls.
  name       TEXT NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 255),
  -- Open text matches Medusa while allowing custom fulfillment integrations.
  type       TEXT NOT NULL CHECK (length(trim(type)) BETWEEN 1 AND 255),
  -- Provider-specific extension data stays valid JSON when present.
  metadata   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Soft deletion keeps historical fulfillment relationships explainable.
  deleted_at TIMESTAMPTZ
);

-- Medusa 2.20.1 permits one active profile for each merchant-facing name.
CREATE UNIQUE INDEX idx_shipping_profile_active_name
ON shipping_profile (name)
WHERE deleted_at IS NULL;
CREATE INDEX idx_shipping_profile_active_type
ON shipping_profile (type, name, id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.


-- Medusa assigns a default profile when a store has none.
INSERT INTO shipping_profile (id, name, type)
VALUES ('sp_default', 'Default Shipping Profile', 'default');


-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER shipping_profile_touch_updated_at
BEFORE UPDATE ON shipping_profile
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
