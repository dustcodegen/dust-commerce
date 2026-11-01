-- Removes return request lifecycle records and their timestamp trigger.
DROP TRIGGER IF EXISTS return_requests_touch_updated_at ON return_requests;
DROP TABLE IF EXISTS return_requests;
