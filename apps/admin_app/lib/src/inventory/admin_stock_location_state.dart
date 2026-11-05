import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/derive.dart';

part 'admin_stock_location_state.g.dart';

/// Lifecycle of the Inventory/Locations table.
enum AdminStockLocationStatus {
  /// No request has started.
  idle,

  /// A bounded location page is loading.
  loading,

  /// The requested location page is ready.
  ready,

  /// The request failed with display-safe copy.
  failed,
}

/// Immutable state for the authenticated location list.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminStockLocationState with _$AdminStockLocationState {
  /// Creates location state without transport objects in widgets.
  const AdminStockLocationState({
    this.status = AdminStockLocationStatus.idle,
    this.stockLocations = const [],
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

  /// Current normalized location search.
  final String query;

  /// Current explicit location rows.
  final List<AdminStockLocation> stockLocations;

  /// Current request lifecycle.
  final AdminStockLocationStatus status;

  /// Whether a following page exists.
  bool get hasNext => offset + stockLocations.length < count;

  /// Whether a preceding page exists.
  bool get hasPrevious => offset > 0;
}
