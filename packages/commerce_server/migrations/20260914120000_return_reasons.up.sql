-- Defines merchant-controlled reasons customers can select for returned items.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE return_reasons (
  id                      TEXT PRIMARY KEY,
  -- Stable machine value survives label edits and is safe for analytics.
  value                   TEXT NOT NULL CHECK (length(trim(value)) BETWEEN 1 AND 255),
  -- Customer-facing copy is kept separate from the stable machine value.
  label                   TEXT NOT NULL CHECK (length(trim(label)) BETWEEN 1 AND 255),
  -- Optional guidance helps a customer choose the correct reason.
  description             TEXT CHECK (description IS NULL OR length(description) <= 1000),
  -- Parent reasons support Medusa's nested reason taxonomy without CSV fields.
  parent_return_reason_id TEXT REFERENCES return_reasons (id),
  -- Extension data is private and must remain valid JSON when present.
  metadata                TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                          (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                          (CURRENT_TIMESTAMP),
  -- Soft deletion preserves the meaning of historical return items.
  deleted_at TIMESTAMPTZ,
  CHECK (parent_return_reason_id IS NULL OR parent_return_reason_id <> id)
);

-- Active machine values stay unique while retired values remain historical.
CREATE UNIQUE INDEX idx_return_reasons_active_value
ON return_reasons (value)
WHERE deleted_at IS NULL;

CREATE INDEX idx_return_reasons_parent
ON return_reasons (parent_return_reason_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER return_reasons_touch_updated_at
BEFORE UPDATE ON return_reasons
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
