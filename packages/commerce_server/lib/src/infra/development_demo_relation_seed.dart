part of 'development_seed.dart';

/// Relational demo rows are derived from stable product ids to avoid drift.
const _demoRelationStatements = <_Statement>[
  _Statement(r'''
INSERT INTO product_images (id, product_id, url, rank)
SELECT 'img_' || substr(id, 6), id, thumbnail, 0
FROM products WHERE id LIKE 'prod_demo_%'
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_variants
  (id, product_id, title, sku, inventory_quantity)
SELECT
  'var_' || substr(id, 6), id, 'Default',
  'DEMO-' || substr(id, 11),
  CASE WHEN id = 'prod_demo_16' THEN 0 ELSE 8 + CAST(substr(id, 11) AS INTEGER)
  END
FROM products WHERE id LIKE 'prod_demo_%'
  AND id != 'prod_demo_21'
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_variants
  (id, product_id, title, sku, inventory_quantity)
VALUES
  ('var_demo_21_s_black', 'prod_demo_21', 'S / Black',
   'DEMO-21-S-BLACK', 14),
  ('var_demo_21_m_white', 'prod_demo_21', 'M / White',
   'DEMO-21-M-WHITE', 15)
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO variant_prices (variant_id, currency_code, amount)
SELECT variant.id, currency.code,
  CASE product.type_id
    WHEN 'ptyp_shirt' THEN currency.shirt
    WHEN 'ptyp_sweatshirt' THEN currency.sweatshirt
    WHEN 'ptyp_pants' THEN currency.pants
    ELSE currency.shorts
  END + CAST(substr(product.id, 11) AS INTEGER) * currency.step
FROM product_variants variant
JOIN products product ON product.id = variant.product_id
CROSS JOIN (
  SELECT 'usd' AS code, 1800 AS shirt, 3800 AS sweatshirt,
         3200 AS pants, 2400 AS shorts, 25 AS step
  UNION ALL
  SELECT 'eur', 1200, 2600, 2200, 1700, 20
) currency
WHERE product.id LIKE 'prod_demo_%'
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_product_options
  (id, product_id, product_option_id)
VALUES
  ('prodopt_demo_21_size', 'prod_demo_21', 'opt_size'),
  ('prodopt_demo_21_color', 'prod_demo_21', 'opt_color')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_product_option_values
  (id, product_product_option_id, product_option_value_id)
VALUES
  ('prodoptval_demo_21_size_s', 'prodopt_demo_21_size', 'optval_size_s'),
  ('prodoptval_demo_21_size_m', 'prodopt_demo_21_size', 'optval_size_m'),
  ('prodoptval_demo_21_color_black', 'prodopt_demo_21_color',
   'optval_color_black'),
  ('prodoptval_demo_21_color_white', 'prodopt_demo_21_color',
   'optval_color_white')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO variant_option_values
  (variant_id, option_id, option_value_id)
VALUES
  ('var_demo_21_s_black', 'opt_size', 'optval_size_s'),
  ('var_demo_21_s_black', 'opt_color', 'optval_color_black'),
  ('var_demo_21_m_white', 'opt_size', 'optval_size_m'),
  ('var_demo_21_m_white', 'opt_color', 'optval_color_white')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_category_products (product_id, category_id, rank)
SELECT id,
  CASE type_id
    WHEN 'ptyp_shirt' THEN 'pcat_shirts'
    WHEN 'ptyp_sweatshirt' THEN 'pcat_sweatshirts'
    WHEN 'ptyp_pants' THEN 'pcat_pants'
    ELSE 'pcat_merch'
  END,
  CAST(substr(id, 11) AS INTEGER)
FROM products WHERE id LIKE 'prod_demo_%'
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_tags (id, value)
VALUES
  ('ptag_demo_essential', 'Essential'),
  ('ptag_demo_seasonal', 'Seasonal'),
  ('ptag_demo_review', 'Needs review')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO product_tag_products (product_id, tag_id)
SELECT id, CASE status
  WHEN 'published' THEN
    CASE collection_id
      WHEN 'pcol_featured' THEN 'ptag_demo_essential'
      ELSE 'ptag_demo_seasonal'
    END
  ELSE 'ptag_demo_review'
END
FROM products WHERE id LIKE 'prod_demo_%'
ON CONFLICT DO NOTHING
'''),
];

const _demoStatements = <_Statement>[
  ..._demoPickupStatements,
  ..._demoProductStatements,
  ..._demoRelationStatements,
];

/// Adds pickup choices only to the opt-in demo layer, never to production.
const _demoPickupStatements = <_Statement>[
  _Statement(r'''
INSERT INTO shipping_options (id, region_id, name, amount, currency_code)
VALUES
  ('ship_pickup', 'reg_us', 'Store pickup', 0, 'usd'),
  ('ship_eu_pickup', 'reg_eu', 'Store pickup', 0, 'eur')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO shipping_option_fulfillments (
  shipping_option_id, fulfillment_type, pickup_name, pickup_address
)
VALUES
  ('ship_pickup', 'pickup', 'Morrow New York', '100 Broadway, New York, NY'),
  ('ship_eu_pickup', 'pickup', 'Morrow Copenhagen', '1 Morrow Lane, Copenhagen')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO shipping_option_fulfillment_provider (
  shipping_option_id, fulfillment_provider_id, data
)
VALUES
  ('ship_pickup', 'manual', json_build_object('service_code', 'ship_pickup')),
  ('ship_eu_pickup', 'manual', json_build_object('service_code', 'ship_eu_pickup'))
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO shipping_option_shipping_profile (
  shipping_option_id, shipping_profile_id
)
VALUES
  ('ship_pickup', 'sp_default'),
  ('ship_eu_pickup', 'sp_default')
ON CONFLICT DO NOTHING
'''),
];
