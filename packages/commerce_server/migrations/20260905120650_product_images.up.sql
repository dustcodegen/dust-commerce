-- Stores the ordered image gallery for a product independently from variants.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_images (
  id         TEXT PRIMARY KEY,
  product_id TEXT NOT NULL REFERENCES products (id) ON DELETE CASCADE,
  -- Remote merchant asset rendered by the storefront.
  url        TEXT NOT NULL CHECK (length(url) > 0),
  -- Stable ordering avoids relying on insertion order in gallery responses.
  rank       INTEGER NOT NULL CHECK (rank >= 0),
  -- Optional extension data must remain valid JSON.
  metadata   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Soft deletion removes an asset without erasing its audit history.
  deleted_at TIMESTAMPTZ,
  UNIQUE (product_id, rank)
);

CREATE INDEX idx_product_images_product ON product_images (product_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_images_touch_updated_at
BEFORE UPDATE ON product_images
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
