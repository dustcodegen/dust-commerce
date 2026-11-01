-- Removes returned-item quantities and their timestamp trigger.
DROP TRIGGER IF EXISTS return_items_touch_updated_at ON return_items;
DROP TABLE IF EXISTS return_items;
