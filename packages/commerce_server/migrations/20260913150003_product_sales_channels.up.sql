-- Links products to every sales channel through which they may be sold.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_sales_channels (
  -- Stable link identity matches Medusa's product-sales-channel link module.
  id               TEXT PRIMARY KEY,
  -- Product deletion removes only its availability links and owned graph.
  product_id       TEXT NOT NULL REFERENCES products (id) ON DELETE CASCADE,
  -- Channel deletion is restricted so active product availability stays explicit.
  sales_channel_id TEXT NOT NULL REFERENCES sales_channels (id)
                   ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                   (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                   (CURRENT_TIMESTAMP),
  -- Soft deletion supports detaching a product without erasing link history.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_product_sales_channels_active_pair
ON product_sales_channels (product_id, sales_channel_id)
WHERE deleted_at IS NULL;
CREATE INDEX idx_product_sales_channels_channel
ON product_sales_channels (sales_channel_id, product_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.


-- New products default to the first active channel until Admin supports selection.


-- Existing active products receive the same default when this migration lands.
INSERT INTO product_sales_channels (id, product_id, sales_channel_id)
SELECT 'prodsc_' || md5(random()::text || clock_timestamp()::text), product.id, channel.id
FROM products product
CROSS JOIN (
  SELECT id FROM sales_channels
  WHERE is_disabled = 0 AND deleted_at IS NULL
  ORDER BY created_at, id
  LIMIT 1
) channel
WHERE product.deleted_at IS NULL;


-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_sales_channels_touch_updated_at
BEFORE UPDATE ON product_sales_channels
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
