import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';

/// Account setup used by generated-client integration tests.
extension AccountSetup on TestClient {
  /// Registers and signs in the fixed integration-test customer.
  Future<String> customerToken() async {
    (await (post('/store/customers')
              ..json({
                'email': 'ada@example.com',
                'password': 'correct horse battery staple',
                'first_name': 'Ada',
                'last_name': 'Lovelace',
              }))
            .send())
        .assertCreated();
    final signedIn = await (post('/auth/customer/emailpass')
          ..json({
            'email': 'ada@example.com',
            'password': 'correct horse battery staple',
          }))
        .send();
    signedIn.assertOk();
    return (signedIn.json! as Map<String, Object?>)['token']! as String;
  }
}

/// In-memory customer-session persistence for non-widget application tests.
final class MemoryAuthSessionStore implements AuthSessionStore {
  /// Current stored session.
  StoredAuthSession? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<StoredAuthSession?> read() async => value;

  @override
  Future<void> write(IssuedToken token) async {
    value = StoredAuthSession(
      token: token.token,
      expiresAt: token.expiresAt,
    );
  }
}

/// Creates a signed-out account model for routing tests.
AccountViewModel testAccount(CommerceApi api) => AccountViewModel(
      AccountViewModelArgs(api: api, sessions: MemoryAuthSessionStore()),
    );

/// In-memory cart capability persistence for non-widget application tests.
final class MemoryCartIdStore implements CartIdStore {
  /// Stored capabilities by account scope.
  final Map<String, String> values = {};

  /// One failure injected into the next read.
  Object? readError;

  @override
  Future<void> clear(String scope) async => values.remove(scope);

  @override
  Future<String?> read(String scope) async {
    final error = readError;
    readError = null;
    if (error != null) throw error;
    return values[scope];
  }

  @override
  Future<void> write(String scope, String cartId) async {
    values[scope] = cartId;
  }
}

/// Creates an empty cart model for routing tests.
CartViewModel testCart(
  CommerceApi api, {
  MemoryCartIdStore? storage,
  Region? region,
}) =>
    CartViewModel(
      CartViewModelArgs(
        api: api,
        cartIds: storage ?? MemoryCartIdStore(),
        selectedRegion: () => switch (region) {
          final selected? => Some(selected),
          null => const None(),
        },
      ),
    );

/// Seeds the generated-client round-trip catalogue and its public taxonomy.
Future<void> seedRoundTripCatalog(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);

  await run(
    r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    r"VALUES ('reg_us', 'United States', 'usd', 1000, 'us')",
  );
  await run(
    r"INSERT INTO region_payment_providers (region_id, provider_id) "
    r"VALUES ('reg_us', 'manual')",
  );
  await run(
    r"INSERT INTO shipping_options (id, region_id, name, amount, currency_code) "
    r"VALUES ('ship_standard', 'reg_us', 'Standard', 0, 'usd')",
  );
  await run(
    r"INSERT INTO product_collections (id, title, handle) VALUES "
    r"('col_summer', 'Summer', 'summer')",
  );
  await run(
    r"INSERT INTO products (id, collection_id, title, handle, status) VALUES "
    r"('prod_shirt', 'col_summer', 'T-Shirt', 't-shirt', 'published')",
  );
  await run(
    r"INSERT INTO product_categories "
    r"(id, name, handle, parent_category_id) VALUES "
    r"('cat_root', 'Clothing', 'clothing', NULL), "
    r"('cat_shirts', 'Shirts', 'clothing/shirts', 'cat_root')",
  );
  await run(
    r"INSERT INTO product_category_products (product_id, category_id) VALUES "
    r"('prod_shirt', 'cat_shirts')",
  );
  await run(
    r"INSERT INTO product_tags (id, value) VALUES "
    r"('tag_cotton', 'Cotton')",
  );
  await run(
    r"INSERT INTO product_tag_products (product_id, tag_id) VALUES "
    r"('prod_shirt', 'tag_cotton')",
  );
  await run(
    r"INSERT INTO product_variants "
    r"(id, product_id, title, inventory_quantity) VALUES "
    r"('var_small', 'prod_shirt', 'Small', 50), "
    r"('var_large', 'prod_shirt', 'Large', 20)",
  );
  await run(
    r"INSERT INTO product_options (id, title) VALUES "
    r"('opt_size', 'Size')",
  );
  await run(
    r"INSERT INTO product_product_options "
    r"(id, product_id, product_option_id) VALUES "
    r"('prodopt_size', 'prod_shirt', 'opt_size')",
  );
  await run(
    r"INSERT INTO product_option_values (id, option_id, value, rank) VALUES "
    r"('optval_small', 'opt_size', 'Small', 0), "
    r"('optval_large', 'opt_size', 'Large', 1)",
  );
  await run(
    r"INSERT INTO product_product_option_values "
    r"(id, product_product_option_id, product_option_value_id) VALUES "
    r"('prodoptval_small', 'prodopt_size', 'optval_small'), "
    r"('prodoptval_large', 'prodopt_size', 'optval_large')",
  );
  await run(
    r"INSERT INTO variant_option_values "
    r"(variant_id, option_id, option_value_id) VALUES "
    r"('var_small', 'opt_size', 'optval_small'), "
    r"('var_large', 'opt_size', 'optval_large')",
  );
  await run(
    r"INSERT INTO variant_prices (variant_id, currency_code, amount) VALUES "
    r"('var_small', 'usd', 1999), "
    r"('var_large', 'usd', 2199), "
    r"('var_small', 'eur', 1799)",
  );
}
