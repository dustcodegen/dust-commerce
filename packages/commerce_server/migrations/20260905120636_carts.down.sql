-- Reverts only the carts table; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS carts_touch_updated_at ON carts;
DROP TABLE carts;
