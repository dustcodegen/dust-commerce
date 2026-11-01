-- Reverts only the promotions table; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS promotions_touch_updated_at ON promotions;
DROP TABLE promotions;
