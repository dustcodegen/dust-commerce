-- Removes fulfillment providers and their timestamp trigger.
DROP TRIGGER IF EXISTS fulfillment_providers_touch_updated_at ON fulfillment_providers;
DROP TABLE IF EXISTS fulfillment_providers;
