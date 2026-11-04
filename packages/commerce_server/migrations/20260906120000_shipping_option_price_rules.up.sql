-- Defines the cart-value condition that makes one delivery option available.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE shipping_option_price_rules (
  -- Stable identifier lets operational tooling address one rule safely.
  id                 TEXT PRIMARY KEY,
  -- Removing an option removes conditions that can no longer be evaluated.
  shipping_option_id TEXT NOT NULL
                     REFERENCES shipping_options (id) ON DELETE CASCADE,
  -- The measured cart fact is explicit so new rule kinds require a decision.
  attribute          TEXT NOT NULL CHECK (attribute IN ('item_total')),
  -- The comparison is stored rather than inferred from a marketing label.
  operator           TEXT NOT NULL
                     CHECK (operator IN ('gt', 'gte', 'lt', 'lte', 'eq')),
  -- Integer minor units match cart totals without floating-point rounding.
  value              INTEGER NOT NULL CHECK (value >= 0),
  -- Creation time supports audit and deterministic operational inspection.
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  -- The trigger below advances this when an operator edits the rule.
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                     (CURRENT_TIMESTAMP),
  -- Soft deletion withdraws a rule without losing its history immediately.
  deleted_at TIMESTAMPTZ,
  UNIQUE (shipping_option_id, attribute, operator, value)
);

CREATE INDEX idx_shipping_option_price_rules_option
ON shipping_option_price_rules (shipping_option_id)
WHERE deleted_at IS NULL;

-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER shipping_option_price_rules_touch_updated_at
BEFORE UPDATE ON shipping_option_price_rules
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
