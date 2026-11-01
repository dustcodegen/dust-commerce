-- Freezes the single sales channel that governed a placed order's cart.
-- The link is separate because committed order history cannot be altered in place.
CREATE TABLE order_sales_channels (
  -- One row per order prevents its commercial origin from becoming ambiguous.
  order_id         TEXT PRIMARY KEY REFERENCES orders (id) ON DELETE CASCADE,
  -- Channel deletion is restricted; soft deletion retains historical meaning.
  sales_channel_id TEXT NOT NULL REFERENCES sales_channels (id)
                   ON DELETE RESTRICT,
  -- SQLite generates the immutable UTC audit instant for this snapshot.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                   (CURRENT_TIMESTAMP)
);

CREATE INDEX idx_order_sales_channels_channel
ON order_sales_channels (sales_channel_id, order_id);

-- Checkout cannot forget the channel: inserting an order snapshots its cart link
-- inside the same SQLite transaction. Channel-less carts remain valid for legacy
-- and explicitly unscoped Store traffic, matching Medusa's nullable boundary.

