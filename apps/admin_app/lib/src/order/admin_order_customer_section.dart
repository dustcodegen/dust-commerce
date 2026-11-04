import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Customer identity and frozen checkout destinations.
final class AdminOrderCustomerSection extends StatelessWidget {
  /// Creates the customer section.
  const AdminOrderCustomerSection({required this.order, super.key});

  /// Complete merchant order snapshot.
  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: 'Customer',
        child: Column(children: [
          AdminProductDetailRow(
            label: 'Customer',
            value: Text(order.customerName),
          ),
          AdminProductDetailRow(label: 'Email', value: Text(order.email)),
          _AddressGroup(
              label: 'Shipping address', address: order.shippingAddress),
          _AddressGroup(
              label: 'Billing address', address: order.billingAddress),
        ]),
      );
}

final class _AddressGroup extends StatelessWidget {
  const _AddressGroup({required this.label, required this.address});

  final Option<AdminOrderAddress> address;
  final String label;

  @override
  Widget build(BuildContext context) => AdminProductDetailRow(
        label: label,
        value: switch (address) {
          Some(value: final address) => Text(_lines(address).join('\n')),
          None() => adminDetailText(context, null),
        },
      );

  List<String> _lines(AdminOrderAddress address) => [
        '${address.firstName} ${address.lastName}'.trim(),
        if (address.company case Some(:final value)) value,
        address.line1,
        if (address.line2 case Some(:final value)) value,
        [
          address.postalCode,
          address.city,
          if (address.province case Some(:final value)) value,
        ].where((value) => value.isNotEmpty).join(' '),
        address.countryCode.toUpperCase(),
        if (address.phone case Some(:final value)) value,
      ];
}
