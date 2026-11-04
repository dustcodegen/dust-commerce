-- Reverts only provider_identity; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS provider_identity_touch_updated_at ON provider_identity;
DROP TABLE provider_identity;
