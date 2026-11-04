-- Classifies a checkout option as delivery or store pickup.
-- The separate table keeps the original shipping_options migration immutable.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE shipping_option_fulfillments (
  shipping_option_id TEXT PRIMARY KEY
                     REFERENCES shipping_options (id) ON DELETE CASCADE,
  -- Medusa distinguishes pickup fulfillment sets from ordinary delivery.
  fulfillment_type   TEXT NOT NULL DEFAULT 'shipping'
                     CHECK (fulfillment_type IN ('shipping', 'pickup')),
  -- Pickup choices expose a safe merchant-facing store label and address.
  pickup_name        TEXT,
  pickup_address     TEXT,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CHECK (
    (fulfillment_type = 'pickup'
      AND length(trim(pickup_name)) BETWEEN 1 AND 255
      AND length(trim(pickup_address)) BETWEEN 1 AND 500)
    OR
    (fulfillment_type = 'shipping'
      AND pickup_name IS NULL
      AND pickup_address IS NULL)
  )
);

-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER shipping_option_fulfillments_touch_updated_at
BEFORE UPDATE ON shipping_option_fulfillments
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
