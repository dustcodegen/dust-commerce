import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/derive.dart';

part 'admin_shipping_profile_detail_state.g.dart';

/// Lifecycle of one shipping-profile detail route.
enum AdminShippingProfileDetailStatus {
  /// No request has started.
  idle,

  /// The profile is loading.
  loading,

  /// The requested profile is ready.
  ready,

  /// The request failed with display-safe copy.
  failed,
}

/// Explicit state for one fulfillment-profile route.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminShippingProfileDetailState
    with _$AdminShippingProfileDetailState {
  /// Creates detail state without nullable business state.
  const AdminShippingProfileDetailState({
    this.status = AdminShippingProfileDetailStatus.idle,
    this.shippingProfile = const None(),
    this.failure = const None(),
  });

  /// Display-safe failure copy.
  final Option<String> failure;

  /// Loaded explicit profile response.
  final Option<AdminShippingProfile> shippingProfile;

  /// Current request lifecycle.
  final AdminShippingProfileDetailStatus status;
}
