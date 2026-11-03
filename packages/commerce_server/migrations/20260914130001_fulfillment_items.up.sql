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
CREATE OR REPLACE FUNCTION fulfillment_items_validate()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
  fulfillment_order_id TEXT;
  line_order_id TEXT;
  line_quantity INTEGER;
  assigned_quantity INTEGER;
BEGIN
  IF NEW.deleted_at IS NOT NULL THEN RETURN NEW; END IF;
  SELECT order_id INTO fulfillment_order_id
  FROM fulfillments WHERE id = NEW.fulfillment_id;
  SELECT order_id, quantity INTO line_order_id, line_quantity
  FROM order_items WHERE id = NEW.line_item_id;
  IF fulfillment_order_id IS NULL OR line_order_id IS NULL
     OR fulfillment_order_id <> line_order_id THEN
    RAISE EXCEPTION 'fulfillment item must belong to its order';
  END IF;
  SELECT COALESCE(SUM(quantity), 0) INTO assigned_quantity
  FROM fulfillment_items
  WHERE line_item_id = NEW.line_item_id
    AND deleted_at IS NULL AND id <> NEW.id;
  IF assigned_quantity + NEW.quantity > line_quantity THEN
    RAISE EXCEPTION 'fulfillment item quantity exceeds order line';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER fulfillment_items_validate_insert
BEFORE INSERT ON fulfillment_items
FOR EACH ROW EXECUTE FUNCTION fulfillment_items_validate();
CREATE TRIGGER fulfillment_items_validate_update
BEFORE UPDATE ON fulfillment_items
FOR EACH ROW EXECUTE FUNCTION fulfillment_items_validate();


-- Updates preserve the same ownership and cumulative quantity invariants.


-- An order cannot be reassigned after fulfillment items reference its snapshot.
CREATE OR REPLACE FUNCTION fulfillment_items_guard_order_update()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
  IF NEW.order_id <> OLD.order_id AND EXISTS (
    SELECT 1 FROM fulfillment_items
    WHERE fulfillment_id = NEW.id AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'fulfillment order cannot change after items are assigned';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER fulfillment_items_guard_order_update
BEFORE UPDATE OF order_id ON fulfillments
FOR EACH ROW EXECUTE FUNCTION fulfillment_items_guard_order_update();


-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER fulfillment_items_touch_updated_at
BEFORE UPDATE ON fulfillment_items
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
