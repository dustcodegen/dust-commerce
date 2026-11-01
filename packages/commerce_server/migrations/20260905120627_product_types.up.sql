-- Defines reusable merchant product classifications, matching Medusa's model.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_types (
  id          TEXT PRIMARY KEY,
  -- Merchant-facing label selected by products and Admin filters.
  value       TEXT NOT NULL CHECK (length(trim(value)) BETWEEN 1 AND 255),
  -- Optional identifier owned by an upstream catalogue system.
  external_id TEXT CHECK (
    external_id IS NULL OR length(trim(external_id)) BETWEEN 1 AND 255
  ),
  -- Validated JSON supports integrations without widening the core schema.
  metadata    TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  -- Soft deletion retains historical product classification references.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_product_types_value_active
ON product_types (lower(value)) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_product_types_external_id_active
ON product_types (external_id)
WHERE deleted_at IS NULL AND external_id IS NOT NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_types_touch_updated_at
BEFORE UPDATE ON product_types
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
