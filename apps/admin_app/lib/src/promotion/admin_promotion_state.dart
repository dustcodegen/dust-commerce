import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/derive.dart';

part 'admin_promotion_state.g.dart';

/// Lifecycle of the promotions table.
enum AdminPromotionLoadStatus {
  /// No request has started.
  idle,

  /// A bounded promotion page is loading.
  loading,

  /// The requested page is ready.
  ready,

  /// The request failed with display-safe copy.
  failed,
}

/// Immutable state for merchant promotion listing.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminPromotionState with _$AdminPromotionState {
  /// Creates promotion-table state without transport objects in widgets.
  const AdminPromotionState({
    this.status = AdminPromotionLoadStatus.idle,
    this.promotions = const [],
    this.count = 0,
    this.limit = 20,
    this.offset = 0,
    this.query = '',
    this.createdAt = const AdminDateFilter(),
    this.updatedAt = const AdminDateFilter(),
    this.order = AdminPromotionOrder.createdAtDesc,
    this.failure = const None(),
  });

  /// Total rows matching [query].
  final int count;

  /// Creation-time comparison applied by the server.
  final AdminDateFilter createdAt;

  /// Display-safe failure message.
  final Option<String> failure;

  /// Server-owned page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Server-owned stable promotion ordering.
  final AdminPromotionOrder order;

  /// Current explicit promotion rows.
  final List<AdminPromotion> promotions;

  /// Current normalized code search.
  final String query;

  /// Current request lifecycle.
  final AdminPromotionLoadStatus status;

  /// Update-time comparison applied by the server.
  final AdminDateFilter updatedAt;

  /// Whether another server page exists.
  bool get hasNext => offset + promotions.length < count;

  /// Whether a preceding server page exists.
  bool get hasPrevious => offset > 0;

  /// Whether a date filter is active.
  bool get hasFilters => !createdAt.isEmpty || !updatedAt.isEmpty;
}
