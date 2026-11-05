-- Records money returned from a captured payment as its own audit event.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE refunds (
  -- Opaque identifier keeps refund retries separate from provider references.
  id                    TEXT PRIMARY KEY,
  -- This service models one payment per collection without leaking it to Store.
  payment_collection_id TEXT NOT NULL
                        REFERENCES payment_collections (id) ON DELETE CASCADE,
  -- Positive integer minor units prevent meaningless or floating-point refunds.
  amount                INTEGER NOT NULL CHECK (amount > 0),
  -- Currency is frozen so later order changes cannot rewrite the audit event.
  currency_code         TEXT NOT NULL
                        CHECK (length(currency_code) = 3
                               AND currency_code = lower(currency_code)),
  -- A retired reason remains readable for historical payment reconciliation.
  refund_reason_id      TEXT REFERENCES refund_reasons (id),
  -- Optional staff context explains exceptions without overloading the reason.
  note                  TEXT CHECK (note IS NULL OR length(note) <= 1000),
  -- External adapters may retain their opaque refund id without credentials.
  provider_reference    TEXT,
  -- Authenticated Admin ownership is retained while allowing staff deletion.
  created_by            TEXT REFERENCES admin_users (id) ON DELETE SET NULL,
  -- Provider-private response data remains valid JSON and outside Store DTOs.
  metadata              TEXT,
  -- PostgreSQL owns the actual refund event time for every writer.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                        (CURRENT_TIMESTAMP),
  -- Soft deletion retains reconciliation history without presenting it active.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_refunds_payment_active
ON refunds (payment_collection_id, created_at, id)
WHERE deleted_at IS NULL;

CREATE INDEX idx_refunds_reason
ON refunds (refund_reason_id)
WHERE deleted_at IS NULL AND refund_reason_id IS NOT NULL;
