-- Reverts only variant_original_prices; SQLx orders dependency-safe downs.
DROP TRIGGER variant_original_prices_touch_updated_at ON variant_original_prices;
DROP TABLE variant_original_prices;
