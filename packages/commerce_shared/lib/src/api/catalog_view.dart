import 'package:commerce_shared/src/catalog/product.dart';
import 'package:commerce_shared/src/catalog/category.dart';
import 'package:commerce_shared/src/catalog/collection.dart';
import 'package:commerce_shared/src/ordering/order.dart';
import 'package:dust_dart/serde.dart';

part 'catalog_view.g.dart';

/// Public collection inventory used by home and collection routes.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductCollectionListView with _$ProductCollectionListView {
  /// Creates a collection listing.
  const ProductCollectionListView({
    required this.collections,
    required this.count,
  });

  /// Creates a collection listing from JSON.
  factory ProductCollectionListView.fromJson(Map<String, Object?> json) =>
      _$ProductCollectionListViewFromJson(json);

  /// Number of returned collections.
  final int count;

  /// Public collections in stable display order.
  final List<ProductCollection> collections;
}

/// Public category inventory used by nested category routes.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ProductCategoryListView with _$ProductCategoryListView {
  /// Creates a category listing.
  const ProductCategoryListView({
    required this.categories,
    required this.count,
  });

  /// Creates a category listing from JSON.
  factory ProductCategoryListView.fromJson(Map<String, Object?> json) =>
      _$ProductCategoryListViewFromJson(json);

  /// Public categories with parent identifiers.
  final List<ProductCategory> categories;

  /// Number of returned categories.
  final int count;
}

/// A page of the catalogue, as the store answers it.
///
/// Shared rather than server-side: the client decodes this same class, so the
/// paging contract is declared once.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class ProductPageView with _$ProductPageView {
  /// Creates a [ProductPageView].
  const ProductPageView({
    required this.products,
    required this.count,
    required this.total,
    required this.limit,
    required this.offset,
  });

  /// Creates a [ProductPageView] from JSON.
  factory ProductPageView.fromJson(Map<String, Object?> json) =>
      _$ProductPageViewFromJson(json);

  /// How many are on this page.
  final int count;

  /// How many were asked for.
  final int limit;

  /// How many were skipped.
  final int offset;

  /// The products on this page.
  final List<Product> products;

  /// How many published products exist.
  final int total;
}

/// The orders owned by one authenticated customer.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class OrderListView with _$OrderListView {
  /// Creates an [OrderListView].
  const OrderListView({required this.orders, required this.count});

  /// Builds the view of [orders].
  factory OrderListView.of(List<Order> orders) =>
      OrderListView(orders: orders, count: orders.length);

  /// Creates an [OrderListView] from JSON.
  factory OrderListView.fromJson(Map<String, Object?> json) =>
      _$OrderListViewFromJson(json);

  /// How many there are.
  final int count;

  /// The orders, newest first.
  final List<Order> orders;
}
