-- Defines where products are offered and where carts and orders originate.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE sales_channels (
  id          TEXT PRIMARY KEY,
  -- Merchant-facing name is searchable in Admin and copied by response queries.
  name        TEXT NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 255),
  -- Optional context explains the channel without affecting checkout behavior.
  description TEXT CHECK (description IS NULL OR length(description) <= 1000),
  -- Disabled channels remain queryable for historical orders but reject new carts.
  is_disabled INTEGER NOT NULL DEFAULT 0 CHECK (is_disabled IN (0, 1)),
  -- Extension data remains optional and valid JSON when present.
  metadata    TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  -- Soft deletion preserves the meaning of linked historical orders.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_sales_channels_active_name
ON sales_channels (name, id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER sales_channels_touch_updated_at
BEFORE UPDATE ON sales_channels
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
