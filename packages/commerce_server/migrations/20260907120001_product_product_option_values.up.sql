-- Limits a product-option link to the global values offered by that product.
-- UTC timestamps use PostgreSQL TIMESTAMPTZ so every writer stores an instant.
CREATE TABLE product_product_option_values (
  id                        TEXT PRIMARY KEY,
  product_product_option_id TEXT NOT NULL
                            REFERENCES product_product_options (id)
                            ON DELETE CASCADE,
  product_option_value_id   TEXT NOT NULL
                            REFERENCES product_option_values (id)
                            ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT
                            (CURRENT_TIMESTAMP),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT
                            (CURRENT_TIMESTAMP),
  -- Soft deletion removes availability without rewriting old variants.
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_product_product_option_values_active_pair
ON product_product_option_values
  (product_product_option_id, product_option_value_id)
WHERE deleted_at IS NULL;
CREATE INDEX idx_product_product_option_values_value
ON product_product_option_values (product_option_value_id)
WHERE deleted_at IS NULL;

-- A product can only expose values owned by its linked option.
CREATE OR REPLACE FUNCTION product_product_option_values_validate_option()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
DECLARE
  linked_option_id TEXT;
  value_option_id TEXT;
BEGIN
  SELECT product_option_id INTO linked_option_id
  FROM product_product_options
  WHERE id = NEW.product_product_option_id;
  SELECT option_id INTO value_option_id
  FROM product_option_values
  WHERE id = NEW.product_option_value_id;
  IF linked_option_id IS NULL OR value_option_id IS NULL
     OR linked_option_id <> value_option_id THEN
    RAISE EXCEPTION 'product option value does not belong to linked option';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER product_product_option_values_validate_option
BEFORE INSERT OR UPDATE ON product_product_option_values
FOR EACH ROW
EXECUTE FUNCTION product_product_option_values_validate_option();




-- The PostgreSQL trigger maintains updated_at for every writer.



-- PostgreSQL owns mutation timestamps at the database boundary.
CREATE TRIGGER product_product_option_values_touch_updated_at
BEFORE UPDATE ON product_product_option_values
FOR EACH ROW
EXECUTE FUNCTION dust_touch_updated_at();
