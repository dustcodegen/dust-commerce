import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:intl/intl.dart';

/// Medusa's label for a customer credential state.
String adminCustomerAccount(AdminCustomer customer) =>
    customer.hasAccount ? 'Registered' : 'Guest';

/// Customer email or Medusa's visible missing-value placeholder.
String adminCustomerEmail(AdminCustomer customer) => customer.email.match(
      some: (value) => value,
      none: () => '—',
    );

/// Joins only supplied name parts without exposing nullable wire fields.
String adminCustomerName(AdminCustomer customer) {
  return _name(customer.firstName, customer.lastName);
}

/// Joins only supplied profile name parts on the detail route.
String adminCustomerDetailName(AdminCustomerDetail customer) =>
    _name(customer.firstName, customer.lastName);

/// Renders an optional detail value with Medusa's missing-value marker.
String adminCustomerDetailText(Option<String> value) => value.match(
      some: (text) => text,
      none: () => '—',
    );

/// Recipient identity used as the address-card title.
String adminCustomerAddressTitle(AdminCustomerAddress address) =>
    address.addressName.match(
      some: (value) => value,
      none: () => _name(address.firstName, address.lastName),
    );

/// Compact multiline destination shown by Medusa's address listicle.
String adminCustomerAddressLines(AdminCustomerAddress address) {
  final street = [
    address.line1,
    address.line2.match(some: (value) => value, none: () => ''),
  ].where((value) => value.isNotEmpty).join(' ');
  final locality = [
    address.city.match(some: (value) => value, none: () => ''),
    address.province.match(some: (value) => value, none: () => ''),
  ].where((value) => value.isNotEmpty).join(', ');
  final postal = address.postalCode.match(
    some: (value) => value,
    none: () => '',
  );
  return <String>[
    street,
    [locality, postal].where((value) => value.isNotEmpty).join(', '),
    address.countryCode.toUpperCase(),
  ].where((value) => value.isNotEmpty).join('\n');
}

/// Compact local date shown in the customer table.
String adminCustomerCreated(DateTime value) =>
    DateFormat.yMMMd().format(value.toLocal());

/// Full local instant exposed as the date-cell tooltip.
String adminCustomerCreatedFull(DateTime value) =>
    DateFormat.yMMMd().add_jm().format(value.toLocal());

String _name(Option<String> first, Option<String> last) {
  final parts = [
    first.match(some: (value) => value, none: () => ''),
    last.match(some: (value) => value, none: () => ''),
  ].where((value) => value.isNotEmpty);
  return parts.isEmpty ? '—' : parts.join(' ');
}
