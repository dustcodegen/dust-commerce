-- Defines one stable selectable value belonging to a product option.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_option_values (
  id         TEXT PRIMARY KEY,
  option_id  TEXT NOT NULL REFERENCES product_options (id) ON DELETE CASCADE,
  -- Customer-visible choice label; whitespace-only values are never valid.
  value      TEXT NOT NULL CHECK (length(trim(value)) BETWEEN 1 AND 255),
  -- Merchant-defined order keeps sizes and swatches stable in every client.
  rank       INTEGER NOT NULL DEFAULT 0 CHECK (rank >= 0),
  -- Merchant-only extension data stays outside the public response allowlist.
  metadata   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Soft deletion lets historical variants retain their original selection.
  deleted_at TIMESTAMPTZ,
  -- Supports the composite child reference that proves option ownership.
  UNIQUE (id, option_id)
);

CREATE INDEX idx_option_values_option
ON product_option_values (option_id, rank, id)
WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_option_values_option_value
ON product_option_values (option_id, value)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_option_values_touch_updated_at
BEFORE UPDATE ON product_option_values
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
