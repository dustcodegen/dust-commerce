-- Defines curated product groups used by home rails and collection routes.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_collections (
  id         TEXT PRIMARY KEY,
  -- Customer-facing collection name.
  title      TEXT NOT NULL CHECK (length(trim(title)) > 0),
  -- Stable human-readable lookup key used by storefront URLs.
  handle     TEXT NOT NULL CHECK (length(trim(handle)) > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
             (CURRENT_TIMESTAMP),
  -- Soft deletion prevents retired collections from appearing publicly.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_product_collections_handle
ON product_collections (handle) WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_collections_touch_updated_at
BEFORE UPDATE ON product_collections
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
