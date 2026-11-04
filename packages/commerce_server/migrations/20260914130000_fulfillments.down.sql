-- Removes fulfillment lifecycle records and their timestamp trigger.
DROP TRIGGER IF EXISTS fulfillments_touch_updated_at ON fulfillments;
DROP TABLE IF EXISTS fulfillments;
