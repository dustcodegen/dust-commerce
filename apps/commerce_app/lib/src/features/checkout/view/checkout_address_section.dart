import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_address_controllers.dart';
import 'checkout_address_form.dart';
import 'checkout_address_summary.dart';
import 'checkout_step_header.dart';

/// Shipping and optional billing form translated from Medusa Addresses.
final class CheckoutAddressSection extends StatefulWidget {
  /// Creates the address step.
  const CheckoutAddressSection({
    required this.open,
    required this.state,
    required this.countries,
    required this.customer,
    required this.addressBook,
    super.key,
  });

  /// Current authenticated customer's separately loaded address book.
  final AddressBookState addressBook;

  /// Region countries available in the address select.
  final List<String> countries;

  /// Server-proven customer, absent for guest checkout.
  final Customer? customer;

  /// Whether the address form is expanded.
  final bool open;

  /// Retained checkout input and operation state.
  final CheckoutState state;

  @override
  State<CheckoutAddressSection> createState() => _CheckoutAddressSectionState();
}

class _CheckoutAddressSectionState extends State<CheckoutAddressSection> {
  final _form = GlobalKey<FormState>();
  late final CheckoutAddressControllers _shipping;
  late final CheckoutAddressControllers _billing;
  late final TextEditingController _email;
  late bool _sameAsBilling;

  @override
  void initState() {
    super.initState();
    _shipping = CheckoutAddressControllers(widget.state.shipping);
    _billing = CheckoutAddressControllers(widget.state.billing);
    _email = TextEditingController(text: widget.state.email);
    _sameAsBilling = widget.state.sameAsBilling;
  }

  @override
  void dispose() {
    _shipping.dispose();
    _billing.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckoutStepHeader(
            title: context.tr(
              'shop_checkout_shipping_address',
              defaultText: 'Shipping Address',
            ),
            open: widget.open,
            complete: widget.state.shipping.firstName.isNotEmpty,
            onEdit: () => context.pushCheckoutStep('address'),
          ),
          if (widget.open)
            CheckoutAddressForm(
              addressBook: widget.addressBook,
              billing: _billing,
              countries: widget.countries,
              customer: widget.customer,
              email: _email,
              formKey: _form,
              onContinue: _continue,
              onSameAsBillingChanged: (value) {
                setState(() => _sameAsBilling = value);
              },
              onSavedAddressSelected: _selectSavedAddress,
              sameAsBilling: _sameAsBilling,
              shipping: _shipping,
              state: widget.state,
            )
          else
            CheckoutAddressSummary(state: widget.state),
          const CheckoutSectionDivider(),
        ],
      );

  void _selectSavedAddress(CustomerAddressView address) {
    _shipping.replace(CheckoutAddressDraft.fromSavedAddress(address));
    setState(() {});
  }

  Future<void> _continue() async {
    if (!_form.currentState!.validate()) return;
    final checkout = context.readCheckoutViewModel();
    final valid = await checkout.saveAddresses(
      email: _email.text,
      shipping: _shipping.draft,
      billing: _billing.draft,
      sameAsBilling: _sameAsBilling,
    );
    if (!valid || !mounted) return;
    context.pushCheckoutStep('delivery');
  }
}
