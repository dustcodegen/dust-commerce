-- Stores a mutable shopping session before it becomes an immutable order.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE carts (
  id           TEXT PRIMARY KEY,
  region_id    TEXT NOT NULL REFERENCES regions (id),
  -- Nullable because guest checkout must work before account association.
  customer_id  TEXT REFERENCES customers (id),
  email        TEXT,
  metadata     TEXT,
  -- Set once checkout succeeds so completed carts cannot be treated as active.
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
               (CURRENT_TIMESTAMP),
  -- Soft deletion retains recovery/audit context.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_carts_customer ON carts (customer_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER carts_touch_updated_at
BEFORE UPDATE ON carts
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
