-- Stores the sellable product shell; variants own stock and regional prices.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE products (
  id          TEXT PRIMARY KEY,
  -- A product belongs to at most one curated collection, matching Medusa.
  collection_id TEXT REFERENCES product_collections (id) ON DELETE SET NULL,
  title       TEXT NOT NULL CHECK (length(title) > 0),
  -- Optional secondary name shown beneath the merchant-facing title.
  subtitle    TEXT,
  -- Stable human-readable lookup key used by storefront URLs.
  handle      TEXT NOT NULL CHECK (length(handle) > 0),
  description TEXT,
  -- Controls whether promotions may reduce this product's price.
  discountable INTEGER NOT NULL DEFAULT 1 CHECK (discountable IN (0, 1)),
  thumbnail   TEXT,
  -- Merchant-facing composition shown in product information.
  material    TEXT,
  -- ISO 3166-1 alpha-2 country where the product was made.
  origin_country TEXT CHECK (
    origin_country IS NULL OR
    (length(origin_country) = 2 AND origin_country = lower(origin_country))
  ),
  -- Reusable merchant classification; category hierarchy is separate.
  type_id     TEXT REFERENCES product_types (id) ON DELETE SET NULL,
  -- Physical values use the units configured for this store.
  weight      INTEGER CHECK (weight IS NULL OR weight >= 0),
  length      INTEGER CHECK (length IS NULL OR length >= 0),
  width       INTEGER CHECK (width IS NULL OR width >= 0),
  height      INTEGER CHECK (height IS NULL OR height >= 0),
  status      TEXT NOT NULL DEFAULT 'draft'
              CHECK (status IN ('draft', 'published', 'rejected', 'proposed')),
  -- Validated JSON supports merchant extensions without schema-free core data.
  metadata    TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  -- Soft deletion keeps old order references meaningful.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_products_handle ON products (handle)
WHERE deleted_at IS NULL;
CREATE INDEX idx_products_status ON products (status)
WHERE deleted_at IS NULL;
CREATE INDEX idx_products_collection ON products (collection_id)
WHERE deleted_at IS NULL AND collection_id IS NOT NULL;
CREATE INDEX idx_products_type ON products (type_id)
WHERE deleted_at IS NULL AND type_id IS NOT NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER products_touch_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
