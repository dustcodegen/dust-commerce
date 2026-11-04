import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/derive.dart';

part 'admin_promotion_detail_state.g.dart';

/// Lifecycle of one promotion detail route.
enum AdminPromotionDetailStatus {
  /// No request has started.
  idle,

  /// The promotion is loading.
  loading,

  /// The requested promotion is ready.
  ready,

  /// The request failed with display-safe copy.
  failed,
}

/// Explicit state for one promotion detail route.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminPromotionDetailState with _$AdminPromotionDetailState {
  /// Creates detail state without nullable business state.
  const AdminPromotionDetailState({
    this.status = AdminPromotionDetailStatus.idle,
    this.promotion = const None(),
    this.failure = const None(),
  });

  /// Display-safe failure copy.
  final Option<String> failure;

  /// Loaded explicit promotion response.
  final Option<AdminPromotion> promotion;

  /// Current request lifecycle.
  final AdminPromotionDetailStatus status;
}
