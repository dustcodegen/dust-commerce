import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_migrations');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('migrations create every table the implemented slices need', () async {
    final rows = await queryRaw(
      "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
      [],
    ).fetch(database.connection as Executor);
    final tables = rows.map((row) => row.readIndex<String>(0)).toSet();

    expect(
      tables,
      containsAll(<String>[
        ...'carts cart_payment_sessions cart_promotions cart_shipping_methods'
            .split(' '),
        ...'customers admin_users auth_identity auth_tokens'.split(' '),
        'customer_service_requests',
        ...'customer_groups customer_group_customers'.split(' '),
        'email_verifications',
        ...'line_items order_addresses order_items orders'.split(' '),
        ...'product_options product_option_values product_product_options'
            .split(' '),
        'product_product_option_values',
        ...'product_collections product_categories'.split(' '),
        ...'product_category_products product_images product_image_variants'
            .split(' '),
        ...'product_tags product_tag_products product_types'.split(' '),
        ...'product_variants products promotions provider_identity'.split(' '),
        'product_imports',
        ...'regions shipping_options shipping_option_price_rules'.split(' '),
        ...'shipping_profile product_shipping_profile'.split(' '),
        ...'sales_channels cart_sales_channels'.split(' '),
        ...'order_sales_channels product_sales_channels'.split(' '),
        ...'order_transfers variant_option_values variant_prices variant_original_prices'
            .split(' '),
        ...'return_reasons return_requests return_items fulfillments'
            .split(' '),
        ...'fulfillment_items fulfillment_labels'.split(' '),
        ...'stock_location_addresses shipping_option_fulfillment_provider shipping_option_shipping_profile'
            .split(' '),
        ...'stock_locations fulfillment_providers stock_location_fulfillment_providers'
            .split(' '),
        'payment_collections',
        'refund_reasons',
        'refunds',
      ]),
    );
  });

  test('admin profiles keep credentials in auth provider tables', () async {
    final rows = await queryRaw('PRAGMA table_info(admin_users)', [])
        .fetch(database.connection as Executor);
    final columns = rows.map((row) => row.readIndex<String>(1)).toList();

    expect(
      columns,
      containsAll(<String>[
        'id',
        'email',
        'first_name',
        'last_name',
        'status',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
    expect(columns, isNot(contains('password')));
  });

  test('orders keep a separate human-facing display id', () async {
    final rows = await queryRaw('PRAGMA table_info(orders)', [])
        .fetch(database.connection as Executor);
    final columns = rows.map((row) => row.readIndex<String>(1)).toList();

    expect(columns, containsAll(<String>['id', 'display_id', 'cart_id']));
  });

  test('sales channels keep Medusa fields and one cart/order association',
      () async {
    final channelRows = await queryRaw(
      'PRAGMA table_info(sales_channels)',
      [],
    ).fetch(database.connection as Executor);
    final channelColumns =
        channelRows.map((row) => row.readIndex<String>(1)).toList();

    expect(
      channelColumns,
      containsAll(<String>[
        'id',
        'name',
        'description',
        'is_disabled',
        'metadata',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
    for (final table in ['cart_sales_channels', 'order_sales_channels']) {
      final rows = await queryRaw('PRAGMA table_info($table)', [])
          .fetch(database.connection as Executor);
      final columns = rows.map((row) => row.readIndex<String>(1)).toList();
      expect(columns, contains('sales_channel_id'));
      expect(rows.singleWhere((row) => row.readIndex<int>(5) == 1), isNotNull);
    }
  });

  test('product variants contain the complete Medusa detail fields', () async {
    final rows = await queryRaw('PRAGMA table_info(product_variants)', [])
        .fetch(database.connection as Executor);
    final columns = rows.map((row) => row.readIndex<String>(1)).toList();

    expect(
      columns,
      containsAll(<String>[
        'allow_backorder',
        'barcode',
        'ean',
        'height',
        'hs_code',
        'length',
        'manage_inventory',
        'material',
        'mid_code',
        'origin_country',
        'sku',
        'upc',
        'weight',
        'width',
      ]),
    );
  });

  test('product options are reusable through explicit product links', () async {
    final rows = await queryRaw('PRAGMA table_info(product_options)', [])
        .fetch(database.connection as Executor);
    final columns = rows.map((row) => row.readIndex<String>(1)).toList();

    expect(columns, contains('is_exclusive'));
    expect(columns, isNot(contains('product_id')));
    final links = await queryRaw(
      'PRAGMA table_info(product_product_options)',
      [],
    ).fetch(database.connection as Executor);
    expect(
      links.map((row) => row.readIndex<String>(1)),
      containsAll(['product_id', 'product_option_id']),
    );
  });

  test('migrations are idempotent across reopen', () async {
    await database.close();
    final reopened = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    addTearDown(reopened.close);

    final rows = await queryRaw('SELECT COUNT(*) FROM products', [])
        .fetch(reopened.connection as Executor);
    expect(rows.single.readIndex<int>(0), 0);
  });
}
