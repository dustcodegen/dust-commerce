import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_fulfillment_context_state.g.dart';

/// Lifecycle for the create-fulfillment selection data.
enum AdminFulfillmentContextStatus {
  /// No form has requested choices yet.
  idle,

  /// Locations or methods are loading.
  loading,

  /// Choices are ready for merchant input.
  ready,

  /// Choice discovery failed with display-safe copy.
  failed,
}

/// Independent state for location and shipping-method controls.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminFulfillmentContextState with _$AdminFulfillmentContextState {
  /// Creates choice state without transport objects.
  const AdminFulfillmentContextState({
    this.status = AdminFulfillmentContextStatus.idle,
    this.stockLocations = const [],
    this.shippingOptions = const [],
    this.selectedLocationId = const None(),
    this.failure = const None(),
  });

  /// Display-safe discovery failure.
  final Option<String> failure;

  /// Selected inventory origin, absent when no location exists.
  final Option<String> selectedLocationId;

  /// Methods compatible with the selected location and order region.
  final List<AdminFulfillmentShippingOption> shippingOptions;

  /// Active merchant inventory origins.
  final List<AdminStockLocation> stockLocations;

  /// Current discovery lifecycle.
  final AdminFulfillmentContextStatus status;
}
