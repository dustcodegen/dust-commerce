-- Stores a customer's request to take ownership of an existing order.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE order_transfers (
  -- Public opaque identifier used to retry the same transfer safely.
  id                 TEXT PRIMARY KEY,
  -- The order whose ownership may move after the current contact approves.
  order_id           TEXT NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  -- The registered account that will own the order after acceptance.
  customer_id        TEXT NOT NULL REFERENCES customers (id) ON DELETE CASCADE,
  -- Only the SHA-256 fingerprint remains after delivery, so a database read
  -- cannot replay a transfer link that has already left the outbox.
  token_fingerprint  TEXT NOT NULL UNIQUE
                     CHECK (length(token_fingerprint) = 64
                            AND token_fingerprint ~ '^[0-9a-f]{64}$'),
  -- Raw capability retained only while SMTP delivery is pending or leased.
  delivery_token     TEXT,
  -- A request is final after acceptance, refusal, or expiry.
  status             TEXT NOT NULL DEFAULT 'requested'
                     CHECK (status IN ('requested', 'accepted', 'declined', 'expired')),
  -- Tracks whether the capability is still queued, leased, or delivered.
  delivery_status    TEXT NOT NULL DEFAULT 'queued'
                     CHECK (delivery_status IN ('queued', 'sending', 'sent', 'cancelled')),
  -- Counts lease acquisitions for delivery observability and retry diagnosis.
  delivery_attempts  INTEGER NOT NULL DEFAULT 0 CHECK (delivery_attempts >= 0),
  -- A crashed sender can be reclaimed after this short delivery lease expires.
  delivery_lease_until TEXT,
  -- Stores only a sanitised category, never an SMTP credential or token.
  last_delivery_error  TEXT,
  -- The owner decision capability stops working at this UTC instant.
  expires_at TIMESTAMPTZ NOT NULL,
  -- Records when the target customer asked for this ownership transfer.
  requested_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  -- Records the final decision or expiry time; absent while requested.
  decided_at TIMESTAMPTZ,
  -- Records SMTP acceptance, which is delivery rather than mailbox receipt.
  sent_at TIMESTAMPTZ,
  -- PostgreSQL generates the audit timestamp when the row is first inserted.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  -- Audit timestamp maintained by the trigger after every mutation.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  CHECK (
    (status = 'requested' AND decided_at IS NULL) OR
    (status <> 'requested' AND decided_at IS NOT NULL)
  ),
  CHECK (
    (delivery_status = 'queued' AND status = 'requested'
      AND delivery_token IS NOT NULL
      AND delivery_lease_until IS NULL AND sent_at IS NULL) OR
    (delivery_status = 'sending' AND status = 'requested'
      AND delivery_token IS NOT NULL
      AND delivery_lease_until IS NOT NULL AND sent_at IS NULL) OR
    (delivery_status = 'sent' AND delivery_token IS NULL
      AND delivery_lease_until IS NULL AND sent_at IS NOT NULL) OR
    (delivery_status = 'cancelled' AND delivery_token IS NULL
      AND delivery_lease_until IS NULL AND sent_at IS NULL)
  )
);

-- At most one undecided request may compete for an order at a time.
CREATE UNIQUE INDEX idx_order_transfers_active_order
ON order_transfers (order_id)
WHERE status = 'requested';

CREATE INDEX idx_order_transfers_customer
ON order_transfers (customer_id, requested_at DESC);

-- Makes pending or abandoned SMTP work cheap to reclaim.
CREATE INDEX idx_order_transfers_delivery
ON order_transfers (delivery_status, delivery_lease_until)
WHERE delivery_status IN ('queued', 'sending');

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER order_transfers_touch_updated_at
BEFORE UPDATE ON order_transfers
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
