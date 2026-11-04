-- Defines reusable selectable dimensions such as Size or Color.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_options (
  id         TEXT PRIMARY KEY,
  -- Merchant-facing axis label; bounded to keep admin forms predictable.
  title      TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 255),
  -- Exclusive options disappear with their sole product; globals are reusable.
  is_exclusive INTEGER NOT NULL DEFAULT 0 CHECK (is_exclusive IN (0, 1)),
  -- Merchant-only extension data stays outside the public response allowlist.
  metadata   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Soft deletion preserves historical variant and order references.
  deleted_at TIMESTAMPTZ
);

-- Global titles are unique because merchants select them by meaning.
CREATE UNIQUE INDEX idx_product_options_global_title
ON product_options (title)
WHERE deleted_at IS NULL AND is_exclusive = 0;
CREATE INDEX idx_product_options_title ON product_options (title)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_options_touch_updated_at
BEFORE UPDATE ON product_options
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
