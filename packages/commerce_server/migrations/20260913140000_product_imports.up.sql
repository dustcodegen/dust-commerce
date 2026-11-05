-- Stages validated merchant CSV imports before a separate confirmation mutates products.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_imports (
  -- Opaque transaction identifier returned to the Admin import workflow.
  id            TEXT PRIMARY KEY,
  -- Proven merchant who owns and may later confirm this staged import.
  admin_user_id TEXT NOT NULL REFERENCES admin_users (id) ON DELETE RESTRICT,
  -- Original safe display name helps the merchant recognize the staged file.
  filename      TEXT NOT NULL CHECK (length(filename) BETWEEN 1 AND 255),
  -- Validated normalized rows are retained so confirmation never reparses a new file.
  payload_json  TEXT NOT NULL,
  -- Unique products that confirmation would create.
  to_create     INTEGER NOT NULL CHECK (to_create >= 0),
  -- Unique active products that confirmation would update.
  to_update     INTEGER NOT NULL CHECK (to_update >= 0),
  -- Only pending imports can be consumed by the later confirmation operation.
  status        TEXT NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'completed', 'expired')),
  -- Short lifetime limits how long uploaded catalogue data remains actionable.
  expires_at TIMESTAMPTZ NOT NULL,
  -- PostgreSQL generates the audit creation instant in UTC.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  -- Audit mutation instant maintained by the trigger below.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                (CURRENT_TIMESTAMP),
  -- Soft deletion preserves an audit trail without exposing stale imports.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_product_imports_owner_pending
ON product_imports (admin_user_id, expires_at)
WHERE status = 'pending' AND deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_imports_touch_updated_at
BEFORE UPDATE ON product_imports
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
