-- Reverts only variant_prices; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS variant_prices_touch_updated_at ON variant_prices;
DROP TABLE variant_prices;
