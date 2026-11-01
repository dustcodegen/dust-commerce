-- Stores merchant-defined customer segments independently from customer profiles.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE customer_groups (
  -- Opaque identity keeps names editable and safe for route ownership checks.
  id         TEXT PRIMARY KEY,
  -- Names are merchant-facing labels used by search and typed confirmation.
  name       TEXT NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 255),
  -- Creator ownership is audit context, not part of the Admin list response.
  created_by TEXT REFERENCES admin_users (id) ON DELETE SET NULL,
  -- Extension data stays valid JSON and outside explicit response allowlists.
  metadata   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Soft deletion preserves membership history without listing retired groups.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_customer_groups_active_name
ON customer_groups (name)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER customer_groups_touch_updated_at
BEFORE UPDATE ON customer_groups
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
