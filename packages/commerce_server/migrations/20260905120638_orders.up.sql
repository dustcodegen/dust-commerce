-- Stores the immutable commercial snapshot produced by checkout.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE orders (
  id                 TEXT PRIMARY KEY,
  -- Short monotonic number is shown to people; opaque ids remain API keys.
  display_id         INTEGER NOT NULL UNIQUE CHECK (display_id > 0),
  -- One cart can become one order; this is the checkout idempotency boundary.
  cart_id            TEXT NOT NULL UNIQUE REFERENCES carts (id),
  region_id          TEXT NOT NULL REFERENCES regions (id),
  customer_id        TEXT REFERENCES customers (id),
  email              TEXT NOT NULL,
  currency_code      TEXT NOT NULL
                     CHECK (length(currency_code) = 3
                            AND currency_code = lower(currency_code)),
  -- Every monetary value is an integer in the currency's minor unit.
  subtotal           INTEGER NOT NULL CHECK (subtotal >= 0),
  shipping_total     INTEGER NOT NULL DEFAULT 0 CHECK (shipping_total >= 0),
  discount_total     INTEGER NOT NULL DEFAULT 0 CHECK (discount_total >= 0),
  tax                INTEGER NOT NULL CHECK (tax >= 0),
  total              INTEGER NOT NULL CHECK (total >= 0),
  -- Names match Medusa's API so storage and response status cannot drift.
  status             TEXT NOT NULL DEFAULT 'pending'
                     CHECK (status IN (
                       'pending', 'completed', 'canceled', 'archived'
                     )),
  payment_status     TEXT NOT NULL DEFAULT 'awaiting'
                     CHECK (payment_status IN ('awaiting', 'captured', 'refunded')),
  -- Shipping/promotion labels are copied so later catalog edits do not rewrite history.
  shipping_option_id TEXT,
  shipping_name      TEXT,
  promotion_code     TEXT,
  metadata           TEXT,
  -- Business event time is explicit; created_at remains the database insert time.
  placed_at TIMESTAMPTZ NOT NULL,
  -- Cancellation time makes the irreversible lifecycle event auditable.
  canceled_at TIMESTAMPTZ,
  -- Nullable actor preserves the event if an Admin account is later deleted.
  canceled_by        TEXT REFERENCES admin_users (id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  deleted_at TIMESTAMPTZ,
  -- Database checks make a corrupted or contradictory order total impossible.
  CHECK (discount_total <= subtotal + shipping_total),
  CHECK (total = subtotal + shipping_total - discount_total + tax),
  -- Archival preserves a prior cancellation audit instead of erasing history.
  CHECK (
    (status = 'canceled' AND canceled_at IS NOT NULL) OR
    (status = 'archived' AND
      (canceled_by IS NULL OR canceled_at IS NOT NULL)) OR
    (status NOT IN ('canceled', 'archived') AND
      canceled_at IS NULL AND canceled_by IS NULL)
  )
);

CREATE INDEX idx_orders_customer ON orders (customer_id)
WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_email ON orders (email)
WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_placed_at ON orders (placed_at);

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER orders_touch_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
