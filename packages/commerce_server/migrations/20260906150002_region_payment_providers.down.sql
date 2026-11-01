-- Reverts only the region payment-provider table and its owned trigger.
DROP TRIGGER IF EXISTS region_payment_providers_touch_updated_at ON region_payment_providers;
DROP TABLE region_payment_providers;
