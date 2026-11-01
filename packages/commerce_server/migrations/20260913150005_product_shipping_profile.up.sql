-- Links each product to the fulfillment behavior that governs its variants.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_shipping_profile (
  -- Stable link identity matches Medusa's ProductShippingProfile link module.
  id                  TEXT PRIMARY KEY,
  product_id          TEXT NOT NULL REFERENCES products (id) ON DELETE CASCADE,
  shipping_profile_id TEXT NOT NULL REFERENCES shipping_profile (id)
                      ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                      (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                      (CURRENT_TIMESTAMP),
  -- Soft deletion records reassignment without keeping two profiles active.
  deleted_at TIMESTAMPTZ
);

-- Medusa exposes shipping_profile as a scalar product relation, never a list.
CREATE UNIQUE INDEX idx_product_shipping_profile_active_product
ON product_shipping_profile (product_id)
WHERE deleted_at IS NULL;
CREATE INDEX idx_product_shipping_profile_active_profile
ON product_shipping_profile (shipping_profile_id, product_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.


-- New products receive the active default unless Admin later replaces it.


-- Existing active products receive the same deterministic default association.
INSERT INTO product_shipping_profile (id, product_id, shipping_profile_id)
SELECT 'prodsp_' || md5(random()::text || clock_timestamp()::text), product.id, profile.id
FROM products product
CROSS JOIN (
  SELECT id FROM shipping_profile
  WHERE deleted_at IS NULL
  ORDER BY CASE type WHEN 'default' THEN 0 ELSE 1 END, created_at, id
  LIMIT 1
) profile
WHERE product.deleted_at IS NULL;


-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_shipping_profile_touch_updated_at
BEFORE UPDATE ON product_shipping_profile
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
