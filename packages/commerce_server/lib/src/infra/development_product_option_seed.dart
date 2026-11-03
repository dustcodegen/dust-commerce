part of 'development_seed.dart';

final _productOptionStatements = <_Statement>[
  const _Statement(r'''
INSERT INTO product_options (id, title, is_exclusive)
VALUES ('opt_size', 'Size', 0), ('opt_color', 'Color', 0)
ON CONFLICT DO NOTHING
'''),
  const _Statement(r'''
INSERT INTO product_option_values (id, option_id, value, rank)
VALUES
  ('optval_size_s', 'opt_size', 'S', 0),
  ('optval_size_m', 'opt_size', 'M', 1),
  ('optval_size_l', 'opt_size', 'L', 2),
  ('optval_size_xl', 'opt_size', 'XL', 3),
  ('optval_color_black', 'opt_color', 'Black', 0),
  ('optval_color_white', 'opt_color', 'White', 1)
ON CONFLICT DO NOTHING
'''),
  const _Statement(r'''
INSERT INTO product_product_options
  (id, product_id, product_option_id, created_at)
VALUES
  ('prodopt_tshirt_size', 'prod_tshirt', 'opt_size', CURRENT_TIMESTAMP),
  ('prodopt_tshirt_color', 'prod_tshirt', 'opt_color',
   CURRENT_TIMESTAMP + INTERVAL '1 microsecond'),
  ('prodopt_sweatshirt_size', 'prod_sweatshirt', 'opt_size', CURRENT_TIMESTAMP),
  ('prodopt_sweatpants_size', 'prod_sweatpants', 'opt_size', CURRENT_TIMESTAMP),
  ('prodopt_shorts_size', 'prod_shorts', 'opt_size', CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING
'''),
  const _Statement(r'''
INSERT INTO product_product_option_values
  (id, product_product_option_id, product_option_value_id)
VALUES
  ('prodoptval_tshirt_size_s', 'prodopt_tshirt_size', 'optval_size_s'),
  ('prodoptval_tshirt_size_m', 'prodopt_tshirt_size', 'optval_size_m'),
  ('prodoptval_tshirt_size_l', 'prodopt_tshirt_size', 'optval_size_l'),
  ('prodoptval_tshirt_size_xl', 'prodopt_tshirt_size', 'optval_size_xl'),
  ('prodoptval_tshirt_color_black', 'prodopt_tshirt_color',
   'optval_color_black'),
  ('prodoptval_tshirt_color_white', 'prodopt_tshirt_color',
   'optval_color_white'),
  ('prodoptval_sweatshirt_size_s', 'prodopt_sweatshirt_size', 'optval_size_s'),
  ('prodoptval_sweatshirt_size_m', 'prodopt_sweatshirt_size', 'optval_size_m'),
  ('prodoptval_sweatpants_size_s', 'prodopt_sweatpants_size', 'optval_size_s'),
  ('prodoptval_sweatpants_size_m', 'prodopt_sweatpants_size', 'optval_size_m'),
  ('prodoptval_shorts_size_s', 'prodopt_shorts_size', 'optval_size_s'),
  ('prodoptval_shorts_size_m', 'prodopt_shorts_size', 'optval_size_m')
ON CONFLICT DO NOTHING
'''),
  const _Statement(r'''
INSERT INTO product_variants
  (id, product_id, title, sku, inventory_quantity)
VALUES
  ('var_tshirt_s_black', 'prod_tshirt', 'S / Black', 'TSHIRT-S-BLACK', 20),
  ('var_tshirt_s_white', 'prod_tshirt', 'S / White', 'TSHIRT-S-WHITE', 20),
  ('var_tshirt_m_black', 'prod_tshirt', 'M / Black', 'TSHIRT-M-BLACK', 20),
  ('var_tshirt_m_white', 'prod_tshirt', 'M / White', 'TSHIRT-M-WHITE', 20),
  ('var_tshirt_l_black', 'prod_tshirt', 'L / Black', 'TSHIRT-L-BLACK', 20),
  ('var_tshirt_l_white', 'prod_tshirt', 'L / White', 'TSHIRT-L-WHITE', 20),
  ('var_tshirt_xl_black', 'prod_tshirt', 'XL / Black', 'TSHIRT-XL-BLACK', 20),
  ('var_tshirt_xl_white', 'prod_tshirt', 'XL / White', 'TSHIRT-XL-WHITE', 20),
  ('var_sweatshirt_s', 'prod_sweatshirt', 'S', 'SWEATSHIRT-S', 20),
  ('var_sweatshirt_m', 'prod_sweatshirt', 'M', 'SWEATSHIRT-M', 20),
  ('var_sweatpants_s', 'prod_sweatpants', 'S', 'SWEATPANTS-S', 20),
  ('var_sweatpants_m', 'prod_sweatpants', 'M', 'SWEATPANTS-M', 20),
  ('var_shorts_s', 'prod_shorts', 'S', 'SHORTS-S', 20),
  ('var_shorts_m', 'prod_shorts', 'M', 'SHORTS-M', 20)
ON CONFLICT DO NOTHING
'''),
];

final _variantOptionStatements = <_Statement>[
  const _Statement(r'''
INSERT INTO variant_option_values
  (variant_id, option_id, option_value_id)
VALUES
  ('var_tshirt_s_black', 'opt_size', 'optval_size_s'),
  ('var_tshirt_s_black', 'opt_color', 'optval_color_black'),
  ('var_tshirt_s_white', 'opt_size', 'optval_size_s'),
  ('var_tshirt_s_white', 'opt_color', 'optval_color_white'),
  ('var_tshirt_m_black', 'opt_size', 'optval_size_m'),
  ('var_tshirt_m_black', 'opt_color', 'optval_color_black'),
  ('var_tshirt_m_white', 'opt_size', 'optval_size_m'),
  ('var_tshirt_m_white', 'opt_color', 'optval_color_white'),
  ('var_tshirt_l_black', 'opt_size', 'optval_size_l'),
  ('var_tshirt_l_black', 'opt_color', 'optval_color_black'),
  ('var_tshirt_l_white', 'opt_size', 'optval_size_l'),
  ('var_tshirt_l_white', 'opt_color', 'optval_color_white'),
  ('var_tshirt_xl_black', 'opt_size', 'optval_size_xl'),
  ('var_tshirt_xl_black', 'opt_color', 'optval_color_black'),
  ('var_tshirt_xl_white', 'opt_size', 'optval_size_xl'),
  ('var_tshirt_xl_white', 'opt_color', 'optval_color_white'),
  ('var_sweatshirt_s', 'opt_size', 'optval_size_s'),
  ('var_sweatshirt_m', 'opt_size', 'optval_size_m'),
  ('var_sweatpants_s', 'opt_size', 'optval_size_s'),
  ('var_sweatpants_m', 'opt_size', 'optval_size_m'),
  ('var_shorts_s', 'opt_size', 'optval_size_s'),
  ('var_shorts_m', 'opt_size', 'optval_size_m')
ON CONFLICT DO NOTHING
'''),
];
