-- Reverts only the regions table; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS regions_touch_updated_at ON regions;
DROP TABLE regions;
