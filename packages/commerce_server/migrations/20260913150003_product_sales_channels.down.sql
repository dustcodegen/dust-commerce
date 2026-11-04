-- Removes product availability links and their database-owned maintenance.
DROP TRIGGER IF EXISTS product_sales_channels_attach_product_after_insert ON product_sales_channels;
DROP TRIGGER IF EXISTS product_sales_channels_attach_product_after_insert ON products;
DROP TRIGGER IF EXISTS product_sales_channels_touch_updated_at ON product_sales_channels;
DROP TABLE IF EXISTS product_sales_channels;
DROP FUNCTION IF EXISTS dust_attach_product_sales_channel();
