-- Stores carrier tracking and printable-label links created with a shipment.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE fulfillment_labels (
  -- Opaque identity keeps repeated provider tracking numbers independently addressable.
  id              TEXT PRIMARY KEY,
  -- A label has no lifecycle outside its fulfillment and is removed with it.
  fulfillment_id  TEXT NOT NULL REFERENCES fulfillments (id) ON DELETE CASCADE,
  -- Providers may omit tracking text when only a printable label URL exists.
  tracking_number TEXT NOT NULL CHECK (length(tracking_number) <= 255),
  -- Empty and # match Medusa's safe placeholder behavior for missing links.
  tracking_url    TEXT NOT NULL CHECK (
    length(tracking_url) <= 2048 AND (
      tracking_url IN ('', '#') OR
      lower(tracking_url) LIKE 'http://%' OR
      lower(tracking_url) LIKE 'https://%'
    )
  ),
  -- Printable label links use the same stored-XSS-safe scheme boundary.
  label_url       TEXT NOT NULL CHECK (
    length(label_url) <= 2048 AND (
      label_url IN ('', '#') OR
      lower(label_url) LIKE 'http://%' OR
      lower(label_url) LIKE 'https://%'
    )
  ),
  -- SQLite owns creation time so every shipment writer records consistent UTC.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                  (CURRENT_TIMESTAMP),
  -- The trigger below owns mutation time; application code never supplies it.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                  (CURRENT_TIMESTAMP),
  -- Soft deletion preserves carrier history without exposing inactive labels.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_fulfillment_labels_active_fulfillment
ON fulfillment_labels (fulfillment_id, created_at, id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER fulfillment_labels_touch_updated_at
BEFORE UPDATE ON fulfillment_labels
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
