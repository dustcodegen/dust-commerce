-- Removes immutable order channel snapshots and their checkout trigger.
DROP TRIGGER IF EXISTS order_sales_channels_snapshot_after_insert ON order_sales_channels;
DROP TABLE IF EXISTS order_sales_channels;
