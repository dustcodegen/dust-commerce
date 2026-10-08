import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_address_controllers.dart';
import 'checkout_address_fields.dart';
import 'checkout_billing_toggle.dart';
import 'checkout_contact_fields.dart';
import 'checkout_primary_action.dart';
import 'checkout_saved_address_selector.dart';

/// Expanded shipping, billing, and contact form for the address step.
final class CheckoutAddressForm extends StatelessWidget {
  /// Creates the editable address form.
  const CheckoutAddressForm({
    required this.addressBook,
    required this.billing,
    required this.countries,
    required this.customer,
    required this.email,
    required this.formKey,
    required this.onContinue,
    required this.onSameAsBillingChanged,
    required this.onSavedAddressSelected,
    required this.sameAsBilling,
    required this.shipping,
    required this.state,
    super.key,
  });

  /// Current customer's independently loaded saved addresses.
  final AddressBookState addressBook;

  /// Separate billing-address controllers.
  final CheckoutAddressControllers billing;

  /// Region country codes accepted by the server.
  final List<String> countries;

  /// Server-proven customer, absent for guest checkout.
  final Customer? customer;

  /// Receipt email controller.
  final TextEditingController email;

  /// Parent-owned validation state.
  final GlobalKey<FormState> formKey;

  /// Validates and persists the address step.
  final Future<void> Function() onContinue;

  /// Changes whether billing reuses shipping.
  final ValueChanged<bool> onSameAsBillingChanged;

  /// Copies a selected customer address into shipping.
  final ValueChanged<CustomerAddressView> onSavedAddressSelected;

  /// Whether billing reuses shipping.
  final bool sameAsBilling;

  /// Shipping and courier-contact controllers.
  final CheckoutAddressControllers shipping;

  /// Checkout request lifecycle.
  final CheckoutState state;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (customer case final customer?) ...[
                CheckoutSavedAddressSelector(
                  customer: customer,
                  state: addressBook,
                  countries: countries,
                  draft: shipping.draft,
                  onSelected: onSavedAddressSelected,
                ),
                if (addressBook.status != AddressBookStatus.ready ||
                    addressBook.shippingAddressesFor(countries).isNotEmpty)
                  const SizedBox(height: 24),
              ],
              CheckoutAddressFields(
                controllers: shipping,
                countries: countries,
              ),
              CheckoutBillingToggle(
                value: sameAsBilling,
                onChanged: onSameAsBillingChanged,
              ),
              CheckoutContactFields(controllers: shipping, email: email),
              if (!sameAsBilling) ...[
                const SizedBox(height: 32),
                const TranslatedText(
                  'shop_checkout_billing_address',
                  defaultText: 'Billing address',
                  style: _billingAddressHeadingStyle,
                ),
                const SizedBox(height: 24),
                CheckoutAddressFields(
                  controllers: billing,
                  countries: countries,
                  includePhone: true,
                ),
              ],
              const SizedBox(height: 36),
              Align(
                alignment: Alignment.centerLeft,
                child: CheckoutPrimaryAction(
                  label: context.tr(
                    'shop_checkout_continue_delivery',
                    defaultText: 'Continue to delivery',
                  ),
                  onPressed: state.isBusy ? null : onContinue,
                ),
              ),
              if (state.status == CheckoutStatus.failed &&
                  state.operation == CheckoutOperation.prepare) ...[
                const SizedBox(height: 12),
                Text(
                  state.message!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      );
}

const _billingAddressHeadingStyle = TextStyle(
  fontSize: 32,
  height: 44 / 32,
);
