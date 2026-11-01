-- Reverts only variant_option_values; SQLx orders dependency-safe downs.
DROP TRIGGER IF EXISTS variant_option_values_touch_updated_at ON variant_option_values;
DROP TABLE variant_option_values;
