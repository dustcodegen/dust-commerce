-- Records customer membership separately so groups and profiles stay independent.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE customer_group_customers (
  -- One membership event has its own identity for remove and re-add history.
  id                TEXT PRIMARY KEY,
  customer_group_id TEXT NOT NULL REFERENCES customer_groups (id)
                    ON DELETE CASCADE,
  customer_id       TEXT NOT NULL REFERENCES customers (id) ON DELETE CASCADE,
  -- Admin ownership remains auditable without entering public responses.
  created_by        TEXT REFERENCES admin_users (id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  -- Soft deletion retains change history while excluding inactive memberships.
  deleted_at TIMESTAMPTZ
);

-- A customer can be an active member of the same group only once.
CREATE UNIQUE INDEX idx_customer_group_customers_active
ON customer_group_customers (customer_group_id, customer_id)
WHERE deleted_at IS NULL;

CREATE INDEX idx_customer_group_customers_customer
ON customer_group_customers (customer_id, customer_group_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER customer_group_customers_touch_updated_at
BEFORE UPDATE ON customer_group_customers
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
