import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_product_detail_state.g.dart';

/// Lifecycle of one merchant product detail request.
enum AdminProductDetailStatus {
  /// No detail request has started.
  idle,

  /// A product detail is loading.
  loading,

  /// The requested detail is ready.
  ready,

  /// A merchant update is being persisted.
  saving,

  /// The request failed with display-safe copy.
  failed,
}

/// Immutable state for the authenticated product detail route.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminProductDetailState with _$AdminProductDetailState {
  /// Creates detail state without transport objects in the widget tree.
  const AdminProductDetailState({
    this.status = AdminProductDetailStatus.idle,
    this.product = const None(),
    this.failure = const None(),
    this.salesChannels = const [],
    this.totalSalesChannels = const None(),
  });

  /// Display-safe failure copy.
  final Option<String> failure;

  /// Explicit admin product allowlist when loaded.
  final Option<AdminProductDetail> product;

  /// Explicit channels through which this product is currently available.
  final List<AdminSalesChannel> salesChannels;

  /// Current request lifecycle.
  final AdminProductDetailStatus status;

  /// Total configured channels, absent only when availability could not load.
  final Option<int> totalSalesChannels;

  /// Whether the general-details drawer must disable mutation controls.
  bool get isSaving => status == AdminProductDetailStatus.saving;
}
