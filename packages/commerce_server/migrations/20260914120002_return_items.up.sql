-- Stores requested quantities against immutable order-line snapshots.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE return_items (
  id                TEXT PRIMARY KEY,
  -- Deleting an uncommitted return removes only its owned item requests.
  return_id         TEXT NOT NULL REFERENCES return_requests (id) ON DELETE CASCADE,
  -- The immutable order item proves title, price and originally bought quantity.
  order_item_id     TEXT NOT NULL REFERENCES order_items (id),
  quantity          INTEGER NOT NULL CHECK (quantity > 0),
  -- Receipt quantities are updated by later merchant operations, never clients.
  received_quantity INTEGER NOT NULL DEFAULT 0
                    CHECK (received_quantity BETWEEN 0 AND quantity),
  -- Damaged received units are excluded from any future stock restoration.
  damaged_quantity INTEGER NOT NULL DEFAULT 0
                    CHECK (damaged_quantity BETWEEN 0 AND received_quantity),
  -- A retired reason remains referentially valid for historical requests.
  reason_id         TEXT REFERENCES return_reasons (id),
  -- Optional item-specific context does not overload the reason label.
  note              TEXT CHECK (note IS NULL OR length(note) <= 1000),
  -- Extension data is private and must remain valid JSON when present.
  metadata          TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                    (CURRENT_TIMESTAMP),
  UNIQUE (return_id, order_item_id)
);

CREATE INDEX idx_return_items_order_item
ON return_items (order_item_id);

CREATE INDEX idx_return_items_reason
ON return_items (reason_id);

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER return_items_touch_updated_at
BEFORE UPDATE ON return_items
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
