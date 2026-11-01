-- Removes carrier labels before their parent fulfillment table is reverted.
DROP TRIGGER IF EXISTS fulfillment_labels_touch_updated_at ON fulfillment_labels;
DROP TABLE IF EXISTS fulfillment_labels;
