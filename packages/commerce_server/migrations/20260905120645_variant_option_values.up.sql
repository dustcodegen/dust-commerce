-- Links a variant to one stable value for each of its product options.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE variant_option_values (
  variant_id     TEXT NOT NULL
                 REFERENCES product_variants (id) ON DELETE CASCADE,
  option_id      TEXT NOT NULL,
  option_value_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                 (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                 (CURRENT_TIMESTAMP),
  -- One row per pair prevents a variant selecting two values for one option.
  PRIMARY KEY (variant_id, option_id),
  -- The composite key prevents linking a value owned by another option.
  FOREIGN KEY (option_value_id, option_id)
    REFERENCES product_option_values (id, option_id) ON DELETE CASCADE
);

CREATE INDEX idx_variant_values_option_value
ON variant_option_values (option_value_id, variant_id);

-- Composite keys identify the exact selection whose timestamp must advance.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER variant_option_values_touch_updated_at
BEFORE UPDATE ON variant_option_values
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
