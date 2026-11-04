import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/derive.dart';

part 'admin_product_type_detail_state.g.dart';

/// Lifecycle of one product-type detail route.
enum AdminProductTypeDetailStatus {
  /// No request has started.
  idle,

  /// The type and linked products are loading.
  loading,

  /// The requested detail is ready.
  ready,

  /// The request failed with display-safe copy.
  failed,
}

/// Product-type identity and its server-paged linked products.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminProductTypeDetailState with _$AdminProductTypeDetailState {
  /// Creates immutable detail state without transport objects in widgets.
  const AdminProductTypeDetailState({
    this.status = AdminProductTypeDetailStatus.idle,
    this.productType = const None(),
    this.products = const [],
    this.count = 0,
    this.limit = 10,
    this.offset = 0,
    this.query = '',
    this.order = AdminProductOrder.titleAsc,
    this.failure = const None(),
  });

  /// Total linked products matching [query].
  final int count;

  /// Display-safe failure copy.
  final Option<String> failure;

  /// Server-owned page size matching Medusa's detail table.
  final int limit;

  /// Number of linked products skipped.
  final int offset;

  /// Server-owned stable product ordering.
  final AdminProductOrder order;

  /// Explicit product-type allowlist when loaded.
  final Option<AdminProductType> productType;

  /// Current allowlisted linked-product rows.
  final List<AdminProduct> products;

  /// Normalized linked-product title or handle search.
  final String query;

  /// Current request lifecycle.
  final AdminProductTypeDetailStatus status;

  /// Whether another product page exists.
  bool get hasNext => offset + products.length < count;

  /// Whether a preceding product page exists.
  bool get hasPrevious => offset > 0;
}
