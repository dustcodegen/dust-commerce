part of 'development_seed.dart';

/// Currency-complete prices kept separate from catalogue structure.
const _variantPriceStatements = <_Statement>[
  _Statement(r'''
INSERT INTO variant_prices
  (variant_id, currency_code, amount)
VALUES
  ('var_tshirt_s_black', 'usd', 1500),
  ('var_tshirt_s_white', 'usd', 1500),
  ('var_tshirt_m_black', 'usd', 1500),
  ('var_tshirt_m_white', 'usd', 1500),
  ('var_tshirt_l_black', 'usd', 1500),
  ('var_tshirt_l_white', 'usd', 1500),
  ('var_tshirt_xl_black', 'usd', 1500),
  ('var_tshirt_xl_white', 'usd', 1500),
  ('var_sweatshirt_s', 'usd', 3500), ('var_sweatshirt_m', 'usd', 3500),
  ('var_sweatpants_s', 'usd', 2900), ('var_sweatpants_m', 'usd', 2900),
  ('var_shorts_s', 'usd', 2200), ('var_shorts_m', 'usd', 2200),
  ('var_tshirt_s_black', 'eur', 1000),
  ('var_tshirt_s_white', 'eur', 1000),
  ('var_tshirt_m_black', 'eur', 1000),
  ('var_tshirt_m_white', 'eur', 1000),
  ('var_tshirt_l_black', 'eur', 1000),
  ('var_tshirt_l_white', 'eur', 1000),
  ('var_tshirt_xl_black', 'eur', 1000),
  ('var_tshirt_xl_white', 'eur', 1000),
  ('var_sweatshirt_s', 'eur', 2300), ('var_sweatshirt_m', 'eur', 2300),
  ('var_sweatpants_s', 'eur', 1900), ('var_sweatpants_m', 'eur', 1900),
  ('var_shorts_s', 'eur', 1500), ('var_shorts_m', 'eur', 1500)
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO variant_original_prices
  (variant_id, currency_code, amount)
VALUES
  ('var_sweatshirt_s', 'usd', 4500),
  ('var_sweatshirt_m', 'usd', 4500),
  ('var_sweatshirt_s', 'eur', 3000),
  ('var_sweatshirt_m', 'eur', 3000)
ON CONFLICT DO NOTHING
'''),
];

/// Region-specific shipping quotes and free-shipping thresholds.
const _shippingPriceStatements = <_Statement>[
  _Statement(r'''
INSERT INTO shipping_options
  (id, region_id, name, amount, currency_code)
VALUES
  ('ship_free', 'reg_us', 'Free shipping', 0, 'usd'),
  ('ship_standard', 'reg_us', 'Standard shipping', 500, 'usd'),
  ('ship_express', 'reg_us', 'Express shipping', 1500, 'usd'),
  ('ship_eu_free', 'reg_eu', 'Free shipping', 0, 'eur'),
  ('ship_eu_standard', 'reg_eu', 'Standard shipping', 500, 'eur'),
  ('ship_eu_express', 'reg_eu', 'Express shipping', 1500, 'eur')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO shipping_option_price_rules
  (id, shipping_option_id, attribute, operator, value)
VALUES
  ('ship_free_minimum', 'ship_free', 'item_total', 'gte', 10000),
  ('ship_eu_free_minimum', 'ship_eu_free', 'item_total', 'gte', 10000)
ON CONFLICT DO NOTHING
'''),
];
