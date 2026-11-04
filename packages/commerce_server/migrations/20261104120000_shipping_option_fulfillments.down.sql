-- Removes pickup/delivery classification before shipping options are reverted.
DROP TRIGGER IF EXISTS shipping_option_fulfillments_touch_updated_at
ON shipping_option_fulfillments;
DROP TABLE IF EXISTS shipping_option_fulfillments;
