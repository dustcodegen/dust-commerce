import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';

final class OptionFailureApi implements CommerceApi {
  const OptionFailureApi(this.delegate);

  final CommerceApi delegate;

  @override
  Future<ProductOptionFilterListView> productOptions({
    int? limit,
    int? offset,
  }) =>
      Future.error(StateError('option discovery unavailable'));

  @override
  Future<ProductPageView> products({
    String? currency,
    String? query,
    String? sortBy,
    String? collection,
    List<String> categoryHandles = const [],
    List<String> labels = const [],
    String? tag,
    int? minPrice,
    int? maxPrice,
    String? onSale,
    List<String> optionValueIds = const [],
    int? limit,
    int? offset,
  }) =>
      delegate.products(
        currency: currency,
        query: query,
        sortBy: sortBy,
        collection: collection,
        categoryHandles: categoryHandles,
        labels: labels,
        tag: tag,
        minPrice: minPrice,
        maxPrice: maxPrice,
        onSale: onSale,
        optionValueIds: optionValueIds,
        limit: limit,
        offset: offset,
      );

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unused API method');
}

Future<void> seedListingPage(CommerceDatabase database) async {
  await queryExecute(
    r'INSERT INTO product_categories (id, name, handle) VALUES ($1, $2, $3)',
    ['cat_accessories', 'Accessories', 'accessories'],
  ).execute(database.executor);
  await queryExecute(
    r'INSERT INTO product_tags (id, value) VALUES ($1, $2)',
    ['tag_gift', 'Gift'],
  ).execute(database.executor);
  for (var index = 1; index <= 13; index++) {
    final suffix = index.toString().padLeft(2, '0');
    final categoryId = index == 13 ? 'cat_accessories' : 'cat_shirts';
    await queryExecute(
      'INSERT INTO products '
      r'(id, collection_id, title, handle, status) VALUES ($1, $2, $3, $4, $5)',
      [
        'prod_$suffix',
        'col_summer',
        'Product $suffix',
        'product-$suffix',
        'published',
      ],
    ).execute(database.executor);
    await queryExecute(
      'INSERT INTO product_variants '
      r'(id, product_id, title, inventory_quantity) VALUES ($1, $2, $3, $4)',
      ['var_$suffix', 'prod_$suffix', 'Default', 10],
    ).execute(database.executor);
    await queryExecute(
      'INSERT INTO variant_prices '
      r'(variant_id, currency_code, amount) VALUES ($1, $2, $3)',
      ['var_$suffix', 'usd', index * 100],
    ).execute(database.executor);
    if (index == 13) {
      await queryExecute(
        'INSERT INTO variant_original_prices '
        r'(variant_id, currency_code, amount) VALUES ($1, $2, $3)',
        ['var_$suffix', 'usd', 1700],
      ).execute(database.executor);
    }
    await queryExecute(
      'INSERT INTO product_category_products '
      r'(product_id, category_id) VALUES ($1, $2)',
      ['prod_$suffix', categoryId],
    ).execute(database.executor);
    if (index == 13) {
      await queryExecute(
        r'INSERT INTO product_tag_products (product_id, tag_id) VALUES ($1, $2)',
        ['prod_$suffix', 'tag_gift'],
      ).execute(database.executor);
    }
  }
}
