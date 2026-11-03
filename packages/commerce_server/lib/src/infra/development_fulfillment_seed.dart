part of 'development_seed.dart';

/// One honest development origin and the provider it is allowed to use.
const _fulfillmentProviderStatements = <_Statement>[
  _Statement(r'''
INSERT INTO stock_location_addresses (
  id, address_1, company, city, country_code, postal_code
) VALUES (
  'laddr_main', '1 Morrow Lane', 'Morrow', 'Copenhagen', 'dk', '1050'
)
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO stock_locations (id, name, address_id)
VALUES ('sloc_main', 'Morrow Warehouse', 'laddr_main')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO fulfillment_providers (id, name)
VALUES ('manual', 'Manual Fulfillment')
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO stock_location_fulfillment_providers (
  stock_location_id, fulfillment_provider_id
) VALUES ('sloc_main', 'manual')
ON CONFLICT DO NOTHING
'''),
];

/// Every seeded checkout option resolves the same explicit manual provider.
const _shippingOptionProviderStatements = <_Statement>[
  _Statement(r'''
INSERT INTO shipping_option_fulfillment_provider (
  shipping_option_id, fulfillment_provider_id, data
)
SELECT id, 'manual', json_build_object('service_code', id)
FROM shipping_options
WHERE id IN (
  'ship_free', 'ship_standard', 'ship_express',
  'ship_eu_free', 'ship_eu_standard', 'ship_eu_express'
)
ON CONFLICT DO NOTHING
'''),
  _Statement(r'''
INSERT INTO shipping_option_shipping_profile (
  shipping_option_id, shipping_profile_id
)
SELECT id, 'sp_default'
FROM shipping_options
WHERE id IN (
  'ship_free', 'ship_standard', 'ship_express',
  'ship_eu_free', 'ship_eu_standard', 'ship_eu_express'
)
ON CONFLICT DO NOTHING
'''),
];
