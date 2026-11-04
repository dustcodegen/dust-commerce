import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_group_detail_state.g.dart';

/// Lifecycle of one protected customer-group detail request.
enum AdminCustomerGroupDetailStatus {
  /// No group request has started.
  idle,

  /// The selected group is loading.
  loading,

  /// The complete group is ready.
  ready,

  /// The group request failed.
  failed,
}

/// Lifecycle of the independently pageable group customer section.
enum AdminCustomerGroupCustomersStatus {
  /// No customer request has started.
  idle,

  /// A group customer page is loading.
  loading,

  /// The group customer page is ready.
  ready,

  /// The customer request failed while group detail remains available.
  failed,
}

/// Immutable state for Medusa's group detail and customer table.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerGroupDetailState with _$AdminCustomerGroupDetailState {
  /// Creates typed detail state without transport objects.
  const AdminCustomerGroupDetailState({
    this.status = AdminCustomerGroupDetailStatus.idle,
    this.customerGroupId = '',
    this.customerGroup = const None(),
    this.failure = const None(),
    this.customersStatus = AdminCustomerGroupCustomersStatus.idle,
    this.customers = const [],
    this.customerCount = 0,
    this.customerLimit = 10,
    this.customerOffset = 0,
    this.customerQuery = '',
    this.hasAccount = const None(),
    this.createdAt = const AdminDateFilter(),
    this.updatedAt = const AdminDateFilter(),
    this.order = AdminCustomerOrder.createdAtDesc,
    this.customerFailure = const None(),
  });

  /// Total customers matching the group table query.
  final int customerCount;

  /// Display-safe customer-section failure.
  final Option<String> customerFailure;

  /// Selected customer-group detail when available.
  final Option<AdminCustomerGroupDetail> customerGroup;

  /// Stable group selected by the route.
  final String customerGroupId;

  /// Fixed Medusa customer-section page size.
  final int customerLimit;

  /// Number of matching customer rows skipped.
  final int customerOffset;

  /// Search scoped to this customer group.
  final String customerQuery;

  /// Merchant-visible customer summaries.
  final List<AdminCustomer> customers;

  /// Independent customer-section lifecycle.
  final AdminCustomerGroupCustomersStatus customersStatus;

  /// Customer creation-time filter.
  final AdminDateFilter createdAt;

  /// Display-safe detail failure.
  final Option<String> failure;

  /// Registered/guest filter for group members.
  final Option<bool> hasAccount;

  /// Allowlisted customer table ordering.
  final AdminCustomerOrder order;

  /// Customer-group detail lifecycle.
  final AdminCustomerGroupDetailStatus status;

  /// Customer update-time filter.
  final AdminDateFilter updatedAt;

  /// Whether another customer page exists.
  bool get hasNextCustomers =>
      customerOffset + customers.length < customerCount;

  /// Whether an earlier customer page exists.
  bool get hasPreviousCustomers => customerOffset > 0;
}
