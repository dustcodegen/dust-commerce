-- Reverts only line_items; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS line_items_touch_updated_at ON line_items;
DROP TABLE line_items;
