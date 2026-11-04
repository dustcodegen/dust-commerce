-- Defines a nested storefront category tree with stable path handles.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_categories (
  id                 TEXT PRIMARY KEY,
  -- Customer-facing category name.
  name               TEXT NOT NULL CHECK (length(trim(name)) > 0),
  description        TEXT,
  -- Full stable route path, such as clothing/shirts for a nested category.
  handle             TEXT NOT NULL CHECK (length(trim(handle)) > 0),
  -- Self-reference establishes the navigation hierarchy without JSON nesting.
  parent_category_id TEXT REFERENCES product_categories (id)
                     ON DELETE SET NULL,
  -- Inactive categories remain editable but never appear in the store.
  is_active          INTEGER NOT NULL DEFAULT 1
                     CHECK (is_active IN (0, 1)),
  -- Sibling display order; identifiers remain independent of presentation.
  rank               INTEGER NOT NULL DEFAULT 0 CHECK (rank >= 0),
  -- Validated JSON supports merchant extensions outside the public contract.
  metadata           TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  deleted_at TIMESTAMPTZ,
  CHECK (parent_category_id IS NULL OR parent_category_id != id)
);

CREATE UNIQUE INDEX idx_product_categories_handle
ON product_categories (handle) WHERE deleted_at IS NULL;
CREATE INDEX idx_product_categories_parent
ON product_categories (parent_category_id, rank)
WHERE deleted_at IS NULL AND is_active = 1;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_categories_touch_updated_at
BEFORE UPDATE ON product_categories
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
