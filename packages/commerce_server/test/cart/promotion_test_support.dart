import 'package:commerce_server/commerce_server.dart';

/// Seeds promotion policy cases shared by the cart promotion tests.
Future<void> seedPromotionFixture(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);

  await run(
    r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    r"VALUES ('reg_us', 'United States', 'usd', 1000, 'us')",
  );
  await run(
    r"INSERT INTO products (id, title, handle, status) VALUES "
    r"('prod_shirt', 'T-Shirt', 't-shirt', 'published')",
  );
  await run(
    r"INSERT INTO product_variants "
    r"(id, product_id, title, inventory_quantity) VALUES "
    r"('var_small', 'prod_shirt', 'Small', 50)",
  );
  await run(
    r"INSERT INTO variant_prices (variant_id, currency_code, amount) VALUES "
    r"('var_small', 'usd', 2000)",
  );
  await run(
    r"INSERT INTO promotions (id, code, type, value, currency_code, ends_at, "
    r"usage_limit, usage_count) VALUES "
    r"('p1', 'SAVE10', 'percentage', 1000, NULL, NULL, NULL, 0), "
    r"('p2', 'TENOFF', 'fixed', 1000, 'usd', NULL, NULL, 0), "
    r"('p3', 'HUGE', 'fixed', 999999, 'usd', NULL, NULL, 0), "
    r"('p4', 'LASTYEAR', 'percentage', 5000, NULL, '2025-01-01T00:00:00.000Z',"
    r" NULL, 0), "
    r"('p5', 'SPENT', 'percentage', 5000, NULL, NULL, 1, 1), "
    r"('p6', 'EUROOFF', 'fixed', 500, 'eur', NULL, NULL, 0)",
  );
}
