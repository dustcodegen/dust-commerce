import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_info_editor.dart';
import 'customer_address_controllers.dart';
import 'customer_address_form.dart';

/// Editable default billing address translated from Medusa's profile editor.
final class ProfileBillingAddressEditor extends StatefulWidget {
  /// Creates the billing editor from current account state.
  const ProfileBillingAddressEditor({
    required this.customer,
    required this.state,
    super.key,
  });

  /// Current public customer profile.
  final Customer customer;

  /// Server-backed address book and active regions.
  final AddressBookState state;

  @override
  State<ProfileBillingAddressEditor> createState() =>
      _ProfileBillingAddressEditorState();
}

class _ProfileBillingAddressEditorState
    extends State<ProfileBillingAddressEditor> {
  final _formKey = GlobalKey<FormState>();
  late CustomerAddressControllers _controllers;
  String? _addressId;

  CustomerAddressView? get _billing => widget.state.addresses
      .where((address) => address.isDefaultBilling)
      .firstOrNull;

  @override
  void initState() {
    super.initState();
    _resetControllers();
  }

  @override
  void didUpdateWidget(covariant ProfileBillingAddressEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_billing?.id == _addressId) return;
    _controllers.dispose();
    _resetControllers();
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _resetControllers() {
    final billing = _billing;
    _addressId = billing?.id;
    _controllers = billing == null
        ? CustomerAddressControllers.forNewAddress(
            phone: widget.customer.phone ?? '',
          )
        : CustomerAddressControllers.fromAddress(billing);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final operation = switch (state.operation) {
      Some(:final value) => value,
      None() => null,
    };
    final mutating = operation == AddressBookOperation.create ||
        operation == AddressBookOperation.update;
    final error = state.status == AddressBookStatus.failed && mutating
        ? switch (state.message) {
            Some(:final value) => value,
            None() => null,
          }
        : null;
    return AccountInfoEditor(
      label: context.tr(
        'shop_account_billing_address',
        defaultText: 'Billing address',
      ),
      currentInfo: _BillingAddressSummary(address: _billing),
      enabled: state.countries.isNotEmpty && !state.isBusy,
      busy: state.status == AddressBookStatus.mutating && mutating,
      error: error,
      onSave: _save,
      editor: Form(
        key: _formKey,
        child: CustomerAddressForm(
          controllers: _controllers,
          countries: state.countries,
          profileBilling: true,
        ),
      ),
    );
  }

  Future<bool> _save() async {
    if (!_formKey.currentState!.validate()) return false;
    final current = _billing;
    final input = _controllers.input(
      isDefaultBilling: true,
      isDefaultShipping: current?.isDefaultShipping ?? false,
    );
    final model = context.readAddressBookViewModel();
    return current == null
        ? model.create(input)
        : model.update(current.id, input);
  }
}

final class _BillingAddressSummary extends StatelessWidget {
  const _BillingAddressSummary({required this.address});

  final CustomerAddressView? address;

  @override
  Widget build(BuildContext context) {
    final value = address;
    if (value == null) {
      return Text(
        context.tr(
          'shop_account_no_billing_address',
          defaultText: 'No billing address',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${value.firstName} ${value.lastName}'),
        if (value.company case final company?) Text(company),
        Text('${value.line1}${value.line2 == null ? '' : ', ${value.line2}'}'),
        Text('${value.postalCode}, ${value.city}'),
        Text(value.countryCode.toUpperCase()),
      ],
    );
  }
}
