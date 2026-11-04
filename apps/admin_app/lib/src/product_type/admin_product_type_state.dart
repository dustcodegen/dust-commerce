import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_product_type_state.g.dart';

/// Lifecycle of the product-types settings table.
enum AdminProductTypeStatus {
  /// No request has started.
  idle,

  /// A product-type page is loading.
  loading,

  /// The requested page is ready.
  ready,

  /// The request failed with display-safe copy.
  failed,
}

/// Immutable state for product-type administration.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminProductTypeState with _$AdminProductTypeState {
  /// Creates list state without transport objects in the widget tree.
  const AdminProductTypeState({
    this.status = AdminProductTypeStatus.idle,
    this.productTypes = const [],
    this.count = 0,
    this.limit = 20,
    this.offset = 0,
    this.query = '',
    this.failure = const None(),
  });

  /// Total rows matching [query].
  final int count;

  /// Display-safe failure message.
  final Option<String> failure;

  /// Server-owned page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Current reusable product classifications.
  final List<AdminProductType> productTypes;

  /// Normalized value search.
  final String query;

  /// Current request lifecycle.
  final AdminProductTypeStatus status;

  /// Whether another page exists after this one.
  bool get hasNext => offset + productTypes.length < count;

  /// Whether a previous page exists.
  bool get hasPrevious => offset > 0;
}
