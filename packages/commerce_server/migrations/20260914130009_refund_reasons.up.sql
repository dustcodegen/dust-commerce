-- Defines merchant-managed reasons that explain independent payment refunds.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE refund_reasons (
  id          TEXT PRIMARY KEY,
  -- Merchant-facing label is shown in the refund decision form and history.
  label       TEXT NOT NULL CHECK (length(trim(label)) BETWEEN 1 AND 255),
  -- Stable code survives label edits and supports provider reconciliation.
  code        TEXT NOT NULL CHECK (length(trim(code)) BETWEEN 1 AND 255),
  -- Optional guidance keeps operational policy separate from the short label.
  description TEXT CHECK (description IS NULL OR length(description) <= 1000),
  -- Extension data remains private and valid JSON when integrations need it.
  metadata    TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  -- Soft deletion preserves the meaning of historical refund decisions.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_refund_reasons_active_code
ON refund_reasons (code)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER refund_reasons_touch_updated_at
BEFORE UPDATE ON refund_reasons
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
