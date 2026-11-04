import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_detail_state.g.dart';

/// Lifecycle of one protected customer-detail request.
enum AdminCustomerDetailStatus {
  /// No profile request has started.
  idle,

  /// The selected profile is loading.
  loading,

  /// The complete profile is ready.
  ready,

  /// The profile request failed.
  failed,
}

/// Lifecycle of the independently pageable customer order section.
enum AdminCustomerOrdersStatus {
  /// No order request has started.
  idle,

  /// A customer-owned order page is loading.
  loading,

  /// The customer-owned order page is ready.
  ready,

  /// The order request failed while the profile remains available.
  failed,
}

/// Immutable state for Medusa's customer profile and order sections.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerDetailState with _$AdminCustomerDetailState {
  /// Creates typed detail state without transport objects.
  const AdminCustomerDetailState({
    this.status = AdminCustomerDetailStatus.idle,
    this.customerId = '',
    this.customer = const None(),
    this.failure = const None(),
    this.ordersStatus = AdminCustomerOrdersStatus.idle,
    this.orders = const [],
    this.orderCount = 0,
    this.orderLimit = 10,
    this.orderOffset = 0,
    this.orderQuery = '',
    this.order = AdminOrderOrder.createdAtDesc,
    this.orderFailure = const None(),
  });

  /// Complete explicit customer allowlist when loaded.
  final Option<AdminCustomerDetail> customer;

  /// Stable customer selected by the route.
  final String customerId;

  /// Display-safe profile failure.
  final Option<String> failure;

  /// Total orders owned by this customer and matching the query.
  final int orderCount;

  /// Display-safe order-section failure.
  final Option<String> orderFailure;

  /// Fixed Medusa customer-order page size.
  final int orderLimit;

  /// Number of matching order rows skipped.
  final int orderOffset;

  /// Allowlisted order table ordering.
  final AdminOrderOrder order;

  /// Search scoped to this customer's order history.
  final String orderQuery;

  /// Merchant-visible immutable order summaries.
  final List<AdminOrder> orders;

  /// Independent order-section lifecycle.
  final AdminCustomerOrdersStatus ordersStatus;

  /// Customer-detail lifecycle.
  final AdminCustomerDetailStatus status;

  /// Whether a later customer-order page exists.
  bool get hasNextOrders => orderOffset + orders.length < orderCount;

  /// Whether an earlier customer-order page exists.
  bool get hasPreviousOrders => orderOffset > 0;
}
