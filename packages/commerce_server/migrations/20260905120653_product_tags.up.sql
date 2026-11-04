-- Defines public discovery labels that can be shared by many products.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_tags (
  id         TEXT PRIMARY KEY,
  -- Customer-facing label; uniqueness is case-insensitive while active.
  value      TEXT NOT NULL CHECK (length(trim(value)) > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_product_tags_value
ON product_tags (lower(value)) WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_tags_touch_updated_at
BEFORE UPDATE ON product_tags
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
