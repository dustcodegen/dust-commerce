-- Removes stock-location provider assignments and their timestamp trigger.
DROP TRIGGER IF EXISTS stock_location_fulfillment_providers_touch_updated_at ON stock_location_fulfillment_providers;
DROP TABLE IF EXISTS stock_location_fulfillment_providers;
