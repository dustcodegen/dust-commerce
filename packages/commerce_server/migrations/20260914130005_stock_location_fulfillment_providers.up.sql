-- Links each stock location to the fulfillment adapters it may use.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE stock_location_fulfillment_providers (
  -- Location removal deletes only its owned provider assignments.
  stock_location_id       TEXT NOT NULL REFERENCES stock_locations (id)
                          ON DELETE CASCADE,
  -- Provider removal deletes selection links but not fulfillment history.
  fulfillment_provider_id TEXT NOT NULL REFERENCES fulfillment_providers (id)
                          ON DELETE CASCADE,
  -- PostgreSQL owns the creation instant for every assignment writer.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                          (CURRENT_TIMESTAMP),
  -- The trigger below owns mutation time; application code never supplies it.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                          (CURRENT_TIMESTAMP),
  -- Soft deletion records detachment and allows explicit reactivation.
  deleted_at TIMESTAMPTZ,
  PRIMARY KEY (stock_location_id, fulfillment_provider_id)
);

CREATE INDEX idx_location_fulfillment_providers_provider_active
ON stock_location_fulfillment_providers (
  fulfillment_provider_id, stock_location_id
)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER stock_location_fulfillment_providers_touch_updated_at
BEFORE UPDATE ON stock_location_fulfillment_providers
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
