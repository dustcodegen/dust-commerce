part of 'development_seed.dart';

/// Region metadata mirrors Medusa's seeded storefront policy defaults.
const _regionStatements = <_Statement>[
  _Statement(r'''
INSERT INTO sales_channels (id, name, description)
VALUES
  ('sc_web', 'Online Store', 'Primary direct-to-consumer storefront'),
  ('sc_wholesale', 'Wholesale', 'Private partner and bulk orders')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO regions
  (id, name, currency_code, tax_rate, countries, metadata)
VALUES
  ('reg_eu', 'Europe', 'eur', 0, 'gb,de,dk,se,fr,es,it',
   '{"return_window_days":30,"free_returns":false,"shipping_rate":10,"handling_days_min":0,"handling_days_max":1,"transit_days_min":2,"transit_days_max":3}'),
  ('reg_us', 'United States', 'usd', 1000, 'us',
   '{"return_window_days":30,"free_returns":false,"shipping_rate":10,"handling_days_min":0,"handling_days_max":1,"transit_days_min":2,"transit_days_max":3}')
ON CONFLICT (id) DO UPDATE SET metadata = COALESCE(regions.metadata, excluded.metadata)
'''),
  _Statement(r'''
INSERT INTO region_payment_providers (region_id, provider_id)
VALUES
  ('reg_eu', 'manual'),
  ('reg_us', 'manual')
ON CONFLICT DO NOTHING
'''),
];
