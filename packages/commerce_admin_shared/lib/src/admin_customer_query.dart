import 'package:dust_dart/derive.dart';

/// Customer-list order values accepted by the Medusa-shaped Admin API.
enum AdminCustomerOrder {
  /// Customer email A to Z.
  emailAsc('email'),

  /// Customer email Z to A.
  emailDesc('-email'),

  /// Customer given name A to Z.
  firstNameAsc('first_name'),

  /// Customer given name Z to A.
  firstNameDesc('-first_name'),

  /// Customer family name A to Z.
  lastNameAsc('last_name'),

  /// Customer family name Z to A.
  lastNameDesc('-last_name'),

  /// Guest profiles before registered profiles.
  hasAccountAsc('has_account'),

  /// Registered profiles before guest profiles.
  hasAccountDesc('-has_account'),

  /// Oldest customer profiles first.
  createdAtAsc('created_at'),

  /// Newest customer profiles first.
  createdAtDesc('-created_at'),

  /// Least recently updated profiles first.
  updatedAtAsc('updated_at'),

  /// Most recently updated profiles first.
  updatedAtDesc('-updated_at');

  const AdminCustomerOrder(this.parameter);

  /// Stable Admin API query value.
  final String parameter;

  /// Parses one allowlisted Admin API query value.
  static Option<AdminCustomerOrder> parse(String parameter) {
    for (final order in values) {
      if (order.parameter == parameter) return Some(order);
    }
    return const None();
  }
}
