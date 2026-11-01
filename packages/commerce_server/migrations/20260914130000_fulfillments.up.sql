-- Records each physical fulfillment created for an immutable order.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE fulfillments (
  -- Opaque identifier is used by Admin fulfillment lifecycle routes.
  id                 TEXT PRIMARY KEY,
  -- Explicit ownership makes authorization and order aggregation unambiguous.
  order_id           TEXT NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  -- Cross-module stock-location id is required even before location UI exists.
  location_id        TEXT NOT NULL CHECK (length(trim(location_id)) > 0),
  -- Cross-module provider id selects the adapter that owns provider data.
  provider_id        TEXT NOT NULL CHECK (length(trim(provider_id)) > 0),
  -- Historical option id is nullable because digital/manual work may omit it.
  shipping_option_id TEXT CHECK (
    shipping_option_id IS NULL OR length(trim(shipping_option_id)) > 0
  ),
  -- PostgreSQL boolean-compatible integer preserves Medusa's required boolean without text coercion.
  requires_shipping  INTEGER NOT NULL DEFAULT 1
                     CHECK (requires_shipping IN (0, 1)),
  -- Packing is a business event and remains absent until explicitly recorded.
  packed_at TIMESTAMPTZ,
  -- Shipment time is written by the later mark-shipped operation.
  shipped_at TIMESTAMPTZ,
  -- Delivery time is written independently because delivery may be manual.
  delivered_at TIMESTAMPTZ,
  -- Cancellation is final and cannot coexist with shipment or delivery.
  canceled_at TIMESTAMPTZ,
  -- Authenticated actor is retained for the irreversible cancellation audit.
  canceled_by        TEXT REFERENCES admin_users (id) ON DELETE SET NULL,
  -- Nullable actor survives staff deletion while retaining the event time.
  marked_shipped_by  TEXT REFERENCES admin_users (id) ON DELETE SET NULL,
  -- Nullable creator records who initiated the fulfillment when authenticated.
  created_by         TEXT REFERENCES admin_users (id) ON DELETE SET NULL,
  -- Provider-private payload must be valid JSON and never enters Store DTOs.
  data               TEXT,
  -- Merchant extension data is private and validated before later decoding.
  metadata           TEXT,
  -- PostgreSQL owns the creation instant so every writer gets consistent UTC.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  -- The trigger below owns mutation time; application code never supplies it.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  -- Soft deletion keeps order history and future item links explainable.
  deleted_at TIMESTAMPTZ,
  CHECK (
    canceled_at IS NULL OR (shipped_at IS NULL AND delivered_at IS NULL)
  ),
  CHECK (canceled_by IS NULL OR canceled_at IS NOT NULL),
  CHECK (marked_shipped_by IS NULL OR shipped_at IS NOT NULL)
);

CREATE INDEX idx_fulfillments_order_active
ON fulfillments (order_id, created_at, id)
WHERE deleted_at IS NULL;

CREATE INDEX idx_fulfillments_location_active
ON fulfillments (location_id, created_at, id)
WHERE deleted_at IS NULL;

CREATE INDEX idx_fulfillments_provider_active
ON fulfillments (provider_id, created_at, id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER fulfillments_touch_updated_at
BEFORE UPDATE ON fulfillments
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
