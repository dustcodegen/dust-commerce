-- Reverts the customer-service inbox and its timestamp trigger in one step.
DROP TRIGGER IF EXISTS customer_service_requests_touch_updated_at ON customer_service_requests;
DROP TABLE IF EXISTS customer_service_requests;
