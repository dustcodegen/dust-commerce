-- Reverts only auth_identity; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS auth_identity_touch_updated_at ON auth_identity;
DROP TABLE auth_identity;
