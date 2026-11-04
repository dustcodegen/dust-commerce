-- Associates a mutable cart with at most one current selling channel.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE cart_sales_channels (
  -- Primary-key ownership prevents an ambiguous multi-channel cart.
  cart_id          TEXT PRIMARY KEY REFERENCES carts (id) ON DELETE CASCADE,
  -- Deletion is restricted so an active or completed cart keeps its origin.
  sales_channel_id TEXT NOT NULL REFERENCES sales_channels (id)
                   ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                   (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                   (CURRENT_TIMESTAMP)
);

CREATE INDEX idx_cart_sales_channels_channel
ON cart_sales_channels (sales_channel_id, cart_id);

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER cart_sales_channels_touch_updated_at
BEFORE UPDATE ON cart_sales_channels
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
