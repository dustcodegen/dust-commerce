-- Reverts only the cart payment-session table and its owned trigger.
DROP TRIGGER IF EXISTS cart_payment_sessions_touch_updated_at ON cart_payment_sessions;
DROP TABLE cart_payment_sessions;
