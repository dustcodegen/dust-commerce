-- Removes fulfillment item snapshots and their relationship guards.
DROP TRIGGER IF EXISTS fulfillment_items_touch_updated_at ON fulfillment_items;
DROP TRIGGER IF EXISTS fulfillment_items_guard_order_update ON fulfillment_items;
DROP TRIGGER IF EXISTS fulfillment_items_validate_update ON fulfillment_items;
DROP TRIGGER IF EXISTS fulfillment_items_validate_insert ON fulfillment_items;
DROP FUNCTION IF EXISTS fulfillment_items_validate();
DROP FUNCTION IF EXISTS fulfillment_items_guard_order_update();
DROP TABLE IF EXISTS fulfillment_items;
