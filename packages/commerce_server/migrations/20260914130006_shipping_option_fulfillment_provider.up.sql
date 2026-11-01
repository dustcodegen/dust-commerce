-- Resolves one fulfillment provider for each existing checkout shipping option.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE shipping_option_fulfillment_provider (
  -- Scalar primary key prevents an option from resolving two providers.
  shipping_option_id       TEXT PRIMARY KEY REFERENCES shipping_options (id)
                           ON DELETE CASCADE,
  -- Active options restrict provider deletion so resolution cannot dangle.
  fulfillment_provider_id TEXT NOT NULL REFERENCES fulfillment_providers (id)
                          ON DELETE RESTRICT,
  -- Provider-private option payload never enters the public Store contract.
  data                     TEXT,
  -- PostgreSQL owns the creation instant for every option-provider assignment.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                           (CURRENT_TIMESTAMP),
  -- The trigger below owns mutation time; application code never supplies it.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                           (CURRENT_TIMESTAMP),
  -- Soft deletion disables resolution while retaining configuration history.
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_shipping_option_provider_active_provider
ON shipping_option_fulfillment_provider (
  fulfillment_provider_id, shipping_option_id
)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER shipping_option_fulfillment_provider_touch_updated_at
BEFORE UPDATE ON shipping_option_fulfillment_provider
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
