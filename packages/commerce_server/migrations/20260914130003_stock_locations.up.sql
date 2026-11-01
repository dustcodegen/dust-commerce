-- Defines merchant stock locations used to source physical fulfillments.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE stock_locations (
  -- Opaque location identity is stored on fulfillments and inventory levels.
  id         TEXT PRIMARY KEY,
  -- Merchant-facing name is searchable in Admin fulfillment selection.
  name       TEXT NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 255),
  -- Address is optional for digital/manual operations and owned separately.
  address_id TEXT REFERENCES stock_location_addresses (id) ON DELETE SET NULL,
  -- Merchant extension data remains private and valid JSON when present.
  metadata   TEXT,
  -- PostgreSQL owns the creation instant for every location writer.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- The trigger below owns mutation time; application code never supplies it.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Soft deletion hides retired locations without rewriting fulfillment history.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_stock_locations_name_active
ON stock_locations (name, id)
WHERE deleted_at IS NULL;

-- One active location owns an address; retired locations release that address.
CREATE UNIQUE INDEX idx_stock_locations_address_active
ON stock_locations (address_id)
WHERE deleted_at IS NULL AND address_id IS NOT NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER stock_locations_touch_updated_at
BEFORE UPDATE ON stock_locations
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
