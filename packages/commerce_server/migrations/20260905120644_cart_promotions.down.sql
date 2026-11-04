-- Reverts only cart_promotions; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS cart_promotions_touch_updated_at ON cart_promotions;
DROP TABLE cart_promotions;
