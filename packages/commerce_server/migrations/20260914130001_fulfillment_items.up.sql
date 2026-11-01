-- Freezes the exact order-line quantities assigned to each fulfillment.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE fulfillment_items (
  -- Opaque identifier is stable across shipment and delivery operations.
  id                TEXT PRIMARY KEY,
  -- The parent owns this snapshot and removes it on a hard order cleanup.
  fulfillment_id    TEXT NOT NULL REFERENCES fulfillments (id) ON DELETE CASCADE,
  -- Provider-facing title is frozen so later catalogue edits cannot change it.
  title             TEXT NOT NULL CHECK (length(trim(title)) > 0),
  -- Positive integer quantity avoids fractional physical inventory movement.
  quantity          INTEGER NOT NULL CHECK (quantity > 0),
  -- Medusa requires provider snapshots even when a source SKU is empty.
  sku               TEXT NOT NULL,
  -- Medusa requires provider snapshots even when a source barcode is empty.
  barcode           TEXT NOT NULL,
  -- Order-line ownership is checked by the relationship triggers below.
  line_item_id      TEXT NOT NULL REFERENCES order_items (id) ON DELETE CASCADE,
  -- Cross-module inventory id stays optional until managed inventory exists.
  inventory_item_id TEXT CHECK (
    inventory_item_id IS NULL OR length(trim(inventory_item_id)) > 0
  ),
  -- PostgreSQL owns the creation instant for every fulfillment-item writer.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  -- The trigger below owns mutation time; application code never supplies it.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  -- Soft deletion preserves provider history while freeing active quantity.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_fulfillment_items_active_pair
ON fulfillment_items (fulfillment_id, line_item_id)
WHERE deleted_at IS NULL;

CREATE INDEX idx_fulfillment_items_line_active
ON fulfillment_items (line_item_id, fulfillment_id)
WHERE deleted_at IS NULL;

CREATE INDEX idx_fulfillment_items_inventory_active
ON fulfillment_items (inventory_item_id, fulfillment_id)
WHERE deleted_at IS NULL AND inventory_item_id IS NOT NULL;

-- A fulfillment can contain only lines owned by its immutable order.


-- Updates preserve the same ownership and cumulative quantity invariants.


-- An order cannot be reassigned after fulfillment items reference its snapshot.


-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER fulfillment_items_touch_updated_at
BEFORE UPDATE ON fulfillment_items
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
