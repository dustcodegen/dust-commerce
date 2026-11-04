import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_product_option_state.g.dart';

/// Lifecycle of the global product-options table.
enum AdminProductOptionStatus {
  /// No request has started.
  idle,

  /// A product-option page is loading.
  loading,

  /// The requested page is ready.
  ready,

  /// The request failed with display-safe copy.
  failed,
}

/// Immutable state for global product-option administration.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminProductOptionState with _$AdminProductOptionState {
  /// Creates list state without transport objects in the widget tree.
  const AdminProductOptionState({
    this.status = AdminProductOptionStatus.idle,
    this.productOptions = const [],
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

  /// Current globally reusable option rows.
  final List<AdminProductOptionSummary> productOptions;

  /// Normalized title search.
  final String query;

  /// Current request lifecycle.
  final AdminProductOptionStatus status;

  /// Whether another page exists after this one.
  bool get hasNext => offset + productOptions.length < count;

  /// Whether a previous page exists.
  bool get hasPrevious => offset > 0;
}
