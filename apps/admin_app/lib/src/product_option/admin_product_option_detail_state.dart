import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_product_option_detail_state.g.dart';

/// Lifecycle of one merchant product-option detail request.
enum AdminProductOptionDetailStatus {
  /// No detail request has started.
  idle,

  /// A product option is loading.
  loading,

  /// The requested option is ready.
  ready,

  /// A merchant update is being persisted.
  saving,

  /// The request failed with display-safe copy.
  failed,
}

/// Immutable state for one product-option detail route.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminProductOptionDetailState with _$AdminProductOptionDetailState {
  /// Creates detail state without transport objects in the widget tree.
  const AdminProductOptionDetailState({
    this.status = AdminProductOptionDetailStatus.idle,
    this.productOption = const None(),
    this.failure = const None(),
  });

  /// Display-safe failure copy.
  final Option<String> failure;

  /// Explicit admin product-option allowlist when loaded.
  final Option<AdminProductOptionDetail> productOption;

  /// Current request lifecycle.
  final AdminProductOptionDetailStatus status;

  /// Whether mutation controls must be disabled.
  bool get isSaving => status == AdminProductOptionDetailStatus.saving;
}
