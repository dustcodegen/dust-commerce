import 'package:commerce_shared/commerce_shared.dart';

/// Source-shaped account overview values derived from server-owned data.
final class AccountOverviewSummary {
  /// Builds the profile metrics and latest five orders shown by Medusa.
  factory AccountOverviewSummary.from({
    required Customer customer,
    required List<CustomerAddressView> addresses,
    required List<Order> orders,
  }) {
    var completed = 0;
    if (customer.email.trim().isNotEmpty) completed++;
    if (_present(customer.firstName) && _present(customer.lastName)) {
      completed++;
    }
    if (_present(customer.phone)) completed++;
    if (addresses.any((address) => address.isDefaultBilling)) completed++;
    return AccountOverviewSummary._(
      profileCompletion: completed * 25,
      addressCount: addresses.length,
      recentOrders: List.unmodifiable(orders.take(5)),
    );
  }

  const AccountOverviewSummary._({
    required this.profileCompletion,
    required this.addressCount,
    required this.recentOrders,
  });

  /// Number of active addresses saved by the authenticated customer.
  final int addressCount;

  /// Completion percentage for email, name, phone, and default billing.
  final int profileCompletion;

  /// At most the five most recent server-ordered purchases.
  final List<Order> recentOrders;
}

bool _present(String? value) => value?.trim().isNotEmpty ?? false;
