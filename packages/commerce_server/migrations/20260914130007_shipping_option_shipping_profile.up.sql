-- Links each shipping option to the product profile it can fulfill.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE shipping_option_shipping_profile (
  -- Scalar primary key keeps Medusa's shipping_profile_id relation unambiguous.
  shipping_option_id  TEXT PRIMARY KEY REFERENCES shipping_options (id)
                      ON DELETE CASCADE,
  -- Active options restrict profile deletion so item filtering cannot dangle.
  shipping_profile_id TEXT NOT NULL REFERENCES shipping_profile (id)
                      ON DELETE RESTRICT,
  -- PostgreSQL owns the creation instant for every option-profile assignment.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                      (CURRENT_TIMESTAMP),
  -- The trigger below owns mutation time; application code never supplies it.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                      (CURRENT_TIMESTAMP),
  -- Soft deletion disables selection while retaining configuration history.
  deleted_at TIMESTAMPTZ
);

-- Admin option discovery filters by profile while excluding retired links.
CREATE INDEX idx_shipping_option_profile_active_profile
ON shipping_option_shipping_profile (shipping_profile_id, shipping_option_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER shipping_option_shipping_profile_touch_updated_at
BEFORE UPDATE ON shipping_option_shipping_profile
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
