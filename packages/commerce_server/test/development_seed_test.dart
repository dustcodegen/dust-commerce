import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  test('development seed is complete and idempotent', () async {
    final directory = await Directory.systemTemp.createTemp('commerce_seed');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });

    await seedDevelopmentStore(database);
    await seedDevelopmentStore(database);

    expect(await _count(database, 'products'), 4);
    expect(await _count(database, 'product_variants'), 14);
    expect(await _count(database, 'variant_prices'), 28);
    expect(await _count(database, 'product_options'), 2);
    expect(await _count(database, 'product_option_values'), 6);
    expect(await _count(database, 'product_product_options'), 5);
    expect(await _count(database, 'product_product_option_values'), 12);
    expect(await _count(database, 'variant_option_values'), 22);
    expect(await _count(database, 'product_images'), 10);
    expect(await _count(database, 'shipping_options'), 6);
    expect(await _count(database, 'shipping_option_price_rules'), 2);
    expect(await _count(database, 'stock_location_addresses'), 1);
    expect(await _count(database, 'stock_locations'), 1);
    expect(await _count(database, 'fulfillment_providers'), 1);
    expect(await _count(database, 'stock_location_fulfillment_providers'), 1);
    expect(await _count(database, 'shipping_option_fulfillment_provider'), 6);
    expect(await _count(database, 'shipping_option_shipping_profile'), 6);
    expect(
      await _where(
        database,
        'shipping_option_shipping_profile',
        "shipping_profile_id = 'sp_default' AND deleted_at IS NULL",
      ),
      6,
    );
    expect(await _count(database, 'promotions'), 1);
    expect(await _count(database, 'regions'), 2);
    expect(await _count(database, 'sales_channels'), 2);
    expect(await _count(database, 'region_payment_providers'), 2);
    expect(await _count(database, 'return_reasons'), 5);
    expect(await _count(database, 'refund_reasons'), 4);
    expect(
      await _where(
        database,
        'return_reasons',
        "value IN ('wrong_size', 'damaged', 'not_as_described', "
            "'changed_mind', 'other')",
      ),
      5,
    );
    expect(await _count(database, 'customers'), 0);
    expect(await _count(database, 'auth_identity'), 0);
    expect(await _count(database, 'auth_tokens'), 0);

    final stocked = await queryScalar<int>(
      'SELECT COUNT(*) FROM product_variants WHERE inventory_quantity > 0',
      const [],
    ).fetchOne(database.executor);
    expect(stocked, const Ok<int, SqlxError>(14));

    final thumbnails = await queryScalar<int>(
      'SELECT COUNT(*) FROM products WHERE thumbnail LIKE \$1',
      ['https://%'],
    ).fetchOne(database.executor);
    expect(thumbnails, const Ok<int, SqlxError>(4));

    final images = await queryScalar<int>(
      "SELECT COUNT(*) FROM product_images WHERE product_id = 'prod_tshirt'",
      const [],
    ).fetchOne(database.executor);
    expect(images, const Ok<int, SqlxError>(4));
  });

  test('demo catalogue adds a varied second admin page', () async {
    final directory = await Directory.systemTemp.createTemp('commerce_demo');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });

    await seedDevelopmentStore(database);
    await seedDevelopmentDemoCatalog(database);
    await seedDevelopmentDemoCatalog(database);

    expect(await _count(database, 'products'), 25);
    expect(await _count(database, 'product_variants'), 36);
    expect(await _count(database, 'variant_prices'), 72);
    expect(await _count(database, 'product_images'), 31);
    expect(await _where(database, 'products', "status = 'published'"), 21);
    expect(await _where(database, 'products', "status = 'draft'"), 2);
    expect(await _where(database, 'products', "status = 'proposed'"), 1);
    expect(await _where(database, 'products', "status = 'rejected'"), 1);
    expect(await _where(database, 'products', "id LIKE 'prod_demo_%'"), 21);
    expect(
      await _where(database, 'product_variants', "sku LIKE 'DEMO-%'"),
      22,
    );
    expect(
      await _where(
        database,
        'variant_option_values',
        "variant_id LIKE 'var_demo_21_%'",
      ),
      4,
    );
  });

  test('support inbox seed is varied and idempotent', () async {
    final directory = await Directory.systemTemp.createTemp('commerce_support');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });

    await seedDevelopmentSupportInbox(database);
    await seedDevelopmentSupportInbox(database);

    expect(await _count(database, 'customer_service_requests'), 5);
    expect(
        await _where(database, 'customer_service_requests', "status = 'open'"),
        2);
    expect(
        await _where(
            database, 'customer_service_requests', "status = 'in_progress'"),
        2);
    expect(
        await _where(database, 'customer_service_requests',
            "status = 'resolved' AND resolved_at IS NOT NULL"),
        1);
  });
}

Future<int> _count(CommerceDatabase database, String table) async {
  final rows = await queryRaw('SELECT COUNT(*) FROM $table', const [])
      .fetch(database.connection as Executor);
  return rows.single.readIndex<int>(0);
}

Future<int> _where(
  CommerceDatabase database,
  String table,
  String predicate,
) async {
  final rows = await queryRaw(
    'SELECT COUNT(*) FROM $table WHERE $predicate',
    const [],
  ).fetch(database.connection as Executor);
  return rows.single.readIndex<int>(0);
}
