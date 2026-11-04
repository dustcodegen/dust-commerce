-- Removes staged product-import transactions and their table-owned objects.
DROP INDEX IF EXISTS idx_product_imports_owner_pending;
DROP TRIGGER IF EXISTS product_imports_touch_updated_at ON product_imports;
DROP TABLE IF EXISTS product_imports;
