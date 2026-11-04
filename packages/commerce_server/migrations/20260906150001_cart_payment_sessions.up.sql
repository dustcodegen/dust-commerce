-- Retains the payment provider chosen while a cart moves through checkout.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE cart_payment_sessions (
  -- A cart has one active provider choice; retrying replaces that choice.
  cart_id     TEXT PRIMARY KEY REFERENCES carts (id) ON DELETE CASCADE,
  -- Public provider identifier; no card or provider secret is stored here.
  provider_id TEXT NOT NULL CHECK (length(trim(provider_id)) > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
              (CURRENT_TIMESTAMP)
);

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER cart_payment_sessions_touch_updated_at
BEFORE UPDATE ON cart_payment_sessions
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
