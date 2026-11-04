-- Removes mutable cart channel associations before the channel table.
DROP TRIGGER IF EXISTS cart_sales_channels_touch_updated_at ON cart_sales_channels;
DROP TABLE IF EXISTS cart_sales_channels;
