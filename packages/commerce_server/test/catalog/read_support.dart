import 'package:commerce_server/commerce_server.dart';

/// Seeds the catalogue states exercised by the storefront read tests.
Future<void> seedCatalogRead(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);

  await run(
    r"INSERT INTO product_collections (id, title, handle) VALUES "
    r"('col_summer', 'Summer', 'summer')",
  );
  await run(
    r"INSERT INTO product_types (id, value) VALUES "
    r"('ptyp_shirt', 'Shirt')",
  );
  await run(
    r"INSERT INTO products "
    r"(id, collection_id, type_id, title, handle, weight, status) VALUES "
    r"('prod_shirt', 'col_summer', 'ptyp_shirt', 'T-Shirt', 't-shirt', 400, 'published'), "
    r"('prod_mug', NULL, NULL, 'Mug', 'mug', NULL, 'published'), "
    r"('prod_secret', NULL, NULL, 'Hoodie', 'secret-hoodie', NULL, 'draft')",
  );
  await run(
    r"INSERT INTO product_categories (id, name, handle) VALUES "
    r"('cat_clothing', 'Clothing', 'clothing'), "
    r"('cat_shirts', 'Shirts', 'clothing/shirts')",
  );
  await run(
    r"UPDATE product_categories SET parent_category_id = 'cat_clothing' "
    r"WHERE id = 'cat_shirts'",
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
    r"INSERT INTO product_images (id, product_id, url, rank) VALUES "
    r"('img_shirt', 'prod_shirt', 'https://example.test/shirt-front.png', 0)",
  );
  await run(
    r"INSERT INTO product_variants "
    r"(id, product_id, title, inventory_quantity) VALUES "
    r"('var_small', 'prod_shirt', 'Small', 5), "
    r"('var_large', 'prod_shirt', 'Large', 2), "
    r"('var_mug', 'prod_mug', 'Default', 3)",
  );
  await run(
    r"INSERT INTO product_images (id, product_id, url, rank) VALUES "
    r"('img_shirt_back', 'prod_shirt', "
    r"'https://example.test/shirt-back.png', 1)",
  );
  await run(
    r"INSERT INTO product_image_variants (image_id, variant_id) VALUES "
    r"('img_shirt', 'var_large')",
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
    r"('var_small', 'eur', 1799), "
    r"('var_mug', 'usd', 999)",
  );
}
