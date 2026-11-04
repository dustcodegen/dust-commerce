-- Removes the sales-channel domain after dependent links have been reverted.
DROP TRIGGER IF EXISTS sales_channels_touch_updated_at ON sales_channels;
DROP TABLE IF EXISTS sales_channels;
