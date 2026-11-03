import 'package:dust_dart/db.dart';

part 'development_taxonomy_seed.dart';
part 'development_pricing_seed.dart';
part 'development_product_option_seed.dart';
part 'development_demo_catalog_seed.dart';
part 'development_demo_relation_seed.dart';
part 'development_fulfillment_seed.dart';
part 'development_support_seed.dart';

/// Inserts the deterministic catalogue used for local storefront development.
///
/// Every statement ignores its known primary keys, so starting the server with
/// seeding enabled twice never duplicates merchant data. This is deliberately
/// opt-in: production startup must never invent catalogue records.
Future<void> seedDevelopmentStore(DatabaseClient database) async {
  await _seed(database, _statements, 'Development seed');
}

/// Adds enough varied records to exercise real Admin paging and filters.
///
/// This remains a separate, idempotent development layer so focused tests can
/// keep using the four-product baseline. Server startup enables both layers
/// only when `COMMERCE_SEED=true`; production never calls either function.
Future<void> seedDevelopmentDemoCatalog(DatabaseClient database) async {
  await _seed(database, _demoStatements, 'Development demo catalogue seed');
}

/// Adds varied guest requests for exercising the protected Admin inbox.
///
/// The stable primary keys make repeated local startup idempotent. Production
/// never calls this opt-in fixture layer.
Future<void> seedDevelopmentSupportInbox(DatabaseClient database) async {
  await _seed(database, _supportStatements, 'Development support inbox seed');
}

Future<void> _seed(
  DatabaseClient database,
  List<_Statement> statements,
  String label,
) async {
  final seeded = await database.transaction<Unit>((transaction) async {
    for (final statement in statements) {
      final result = await transaction.execute(statement.sql, const []);
      if (result case Err(:final error)) return Err(error);
    }
    return const Ok(unit);
  });

  if (seeded case Err(:final error)) {
    throw StateError('$label failed: $error');
  }
}

final _statements = <_Statement>[
  const _Statement(r'''
INSERT INTO sales_channels (id, name, description)
VALUES
  ('sc_web', 'Online Store', 'Primary direct-to-consumer storefront'),
  ('sc_wholesale', 'Wholesale', 'Private partner and bulk orders')
ON CONFLICT DO NOTHING
'''),
  const _Statement(r'''
INSERT INTO regions
  (id, name, currency_code, tax_rate, countries, metadata)
VALUES
  ('reg_eu', 'Europe', 'eur', 0, 'gb,de,dk,se,fr,es,it',
   '{"return_window_days":30,"free_returns":false,"shipping_rate":10,"handling_days_min":0,"handling_days_max":1,"transit_days_min":2,"transit_days_max":3}'),
  ('reg_us', 'United States', 'usd', 1000, 'us',
   '{"return_window_days":30,"free_returns":false,"shipping_rate":10,"handling_days_min":0,"handling_days_max":1,"transit_days_min":2,"transit_days_max":3}')
ON CONFLICT (id) DO UPDATE SET metadata = COALESCE(regions.metadata, excluded.metadata)
'''),
  const _Statement(r'''
INSERT INTO region_payment_providers (region_id, provider_id)
VALUES
  ('reg_eu', 'manual'),
  ('reg_us', 'manual')
ON CONFLICT DO NOTHING
'''),
  ..._fulfillmentProviderStatements,
  ..._taxonomyBeforeProducts,
  const _Statement(r'''
INSERT INTO products
  (id, collection_id, type_id, title, handle, description, thumbnail, weight,
   status)
VALUES
  ('prod_tshirt', 'pcol_featured', 'ptyp_shirt', 'Essential T-Shirt', 't-shirt',
   'A soft cotton essential for building typed storefronts.',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png',
   400, 'published'),
  ('prod_sweatshirt', 'pcol_featured', 'ptyp_sweatshirt',
   'Vintage Sweatshirt', 'sweatshirt',
   'A heavyweight layer for long code-generation sessions.',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png',
   400, 'published'),
  ('prod_sweatpants', 'pcol_featured', 'ptyp_pants',
   'Relaxed Sweatpants', 'sweatpants',
   'Relaxed everyday sweatpants in soft brushed cotton.',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png',
   400, 'published'),
  ('prod_shorts', 'pcol_featured', 'ptyp_shorts', 'Everyday Shorts', 'shorts',
   'Easy cotton shorts for warm days and fast builds.',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png',
   400, 'published')
ON CONFLICT DO NOTHING
'''),
  const _Statement(r'''
INSERT INTO product_shipping_profile (id, product_id, shipping_profile_id)
SELECT 'prodsp_' || product.id, product.id, 'sp_default'
FROM products product
WHERE product.deleted_at IS NULL
ON CONFLICT DO NOTHING
'''),
  ..._taxonomyAfterProducts,
  const _Statement(r'''
INSERT INTO product_images (id, product_id, url, rank)
VALUES
  ('img_tshirt_1', 'prod_tshirt',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png', 0),
  ('img_tshirt_2', 'prod_tshirt',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-back.png', 1),
  ('img_tshirt_3', 'prod_tshirt',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-front.png', 2),
  ('img_tshirt_4', 'prod_tshirt',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-back.png', 3),
  ('img_sweatshirt_1', 'prod_sweatshirt',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png', 0),
  ('img_sweatshirt_2', 'prod_sweatshirt',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-back.png', 1),
  ('img_sweatpants_1', 'prod_sweatpants',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png', 0),
  ('img_sweatpants_2', 'prod_sweatpants',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-back.png', 1),
  ('img_shorts_1', 'prod_shorts',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png', 0),
  ('img_shorts_2', 'prod_shorts',
   'https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-back.png', 1)
ON CONFLICT DO NOTHING
'''),
  ..._productOptionStatements,
  ..._variantPriceStatements,
  ..._variantOptionStatements,
  const _Statement(r'''
INSERT INTO product_image_variants (image_id, variant_id)
SELECT image.id, variant.id
FROM product_images image
JOIN product_variants variant ON variant.product_id = image.product_id
WHERE image.product_id = 'prod_tshirt'
  AND (
    (image.id IN ('img_tshirt_1', 'img_tshirt_2') AND variant.id IN (
      'var_tshirt_s_black', 'var_tshirt_m_black',
      'var_tshirt_l_black', 'var_tshirt_xl_black'
    ))
    OR
    (image.id IN ('img_tshirt_3', 'img_tshirt_4') AND variant.id IN (
      'var_tshirt_s_white', 'var_tshirt_m_white',
      'var_tshirt_l_white', 'var_tshirt_xl_white'
    ))
  )
ON CONFLICT DO NOTHING
'''),
  ..._shippingPriceStatements,
  ..._shippingOptionProviderStatements,
  const _Statement(r'''
INSERT INTO promotions
  (id, code, type, value)
VALUES ('promo_welcome', 'WELCOME10', 'percentage', 1000)
ON CONFLICT DO NOTHING
'''),
  const _Statement(r'''
INSERT INTO return_reasons (id, value, label, description)
VALUES
  ('reason_wrong_size', 'wrong_size', 'Wrong size',
   'The size or fit is not right.'),
  ('reason_damaged', 'damaged', 'Damaged',
   'The item arrived damaged or defective.'),
  ('reason_not_as_described', 'not_as_described', 'Not as described',
   'The item differs from its product description.'),
  ('reason_changed_mind', 'changed_mind', 'Changed my mind',
   'The item is no longer wanted.'),
  ('reason_other', 'other', 'Other',
   'Another reason not listed above.')
ON CONFLICT DO NOTHING
'''),
  const _Statement(r'''
INSERT INTO refund_reasons (id, label, code, description)
VALUES
  ('refund_reason_damaged', 'Damaged', 'damaged',
   'The delivered item was damaged or defective.'),
  ('refund_reason_missing', 'Missing item', 'missing_item',
   'A paid item was not included in the delivery.'),
  ('refund_reason_goodwill', 'Goodwill', 'goodwill',
   'A discretionary customer-service refund.'),
  ('refund_reason_other', 'Other', 'other',
   'Use the note to explain another refund decision.')
ON CONFLICT DO NOTHING
'''),
];

final class _Statement {
  const _Statement(this.sql);

  final String sql;
}
