-- Stores customer-service conversations submitted from the public Store.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE customer_service_requests (
  -- Opaque identity is safe to expose in the submission acknowledgement.
  id              TEXT PRIMARY KEY,
  -- Proven account ownership is optional because guest checkout is supported.
  customer_id     TEXT REFERENCES customers (id) ON DELETE SET NULL,
  -- Contact details are copied so later profile edits do not rewrite history.
  name            TEXT NOT NULL
                  CHECK (length(trim(name)) BETWEEN 1 AND 120),
  email           TEXT NOT NULL
                  CHECK (length(trim(email)) BETWEEN 3 AND 254
                    AND position('@' in email) > 1),
  -- Subject and message retain the exact customer support context.
  subject         TEXT NOT NULL
                  CHECK (length(trim(subject)) BETWEEN 1 AND 160),
  message         TEXT NOT NULL
                  CHECK (length(trim(message)) BETWEEN 1 AND 5000),
  -- Free-form reference also works for guests who only know an order number.
  order_reference TEXT
                  CHECK (order_reference IS NULL OR
                    length(trim(order_reference)) BETWEEN 1 AND 255),
  -- A compact lifecycle is enough for merchant triage without fake replies.
  status          TEXT NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open', 'in_progress', 'resolved')),
  -- Resolution time is an audit fact generated only by the status update.
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                  (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                  (CURRENT_TIMESTAMP),
  CHECK (
    (status = 'resolved' AND resolved_at IS NOT NULL) OR
    (status != 'resolved' AND resolved_at IS NULL)
  )
);

CREATE INDEX idx_customer_service_requests_status
ON customer_service_requests (status, created_at DESC, id DESC);

CREATE INDEX idx_customer_service_requests_customer
ON customer_service_requests (customer_id, created_at DESC)
WHERE customer_id IS NOT NULL;

CREATE INDEX idx_customer_service_requests_email
ON customer_service_requests (email, created_at DESC);

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER customer_service_requests_touch_updated_at
BEFORE UPDATE ON customer_service_requests
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
