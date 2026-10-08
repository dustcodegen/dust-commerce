import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_address_controllers.dart';
import 'checkout_form_controls.dart';

/// The field grid shared by shipping and separate billing addresses.
final class CheckoutAddressFields extends StatelessWidget {
  /// Creates address fields bound to [controllers].
  const CheckoutAddressFields({
    required this.controllers,
    required this.countries,
    this.includePhone = false,
    super.key,
  });

  /// Region country codes offered by the server.
  final List<String> countries;

  /// Controllers for this address block.
  final CheckoutAddressControllers controllers;

  /// Whether this block includes Medusa's standalone billing phone field.
  final bool includePhone;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          CheckoutFieldRow(
            left: CheckoutFormField(
              controller: controllers.firstName,
              label: context.tr(
                'shop_checkout_first_name',
                defaultText: 'First name',
              ),
            ),
            right: CheckoutFormField(
              controller: controllers.lastName,
              label: context.tr(
                'shop_checkout_last_name',
                defaultText: 'Last name',
              ),
            ),
          ),
          const SizedBox(height: 16),
          CheckoutFieldRow(
            left: CheckoutFormField(
              controller: controllers.line1,
              label: context.tr(
                'shop_checkout_address',
                defaultText: 'Address',
              ),
            ),
            right: CheckoutFormField(
              controller: controllers.company,
              label: context.tr(
                'shop_checkout_company',
                defaultText: 'Company',
              ),
              required: false,
            ),
          ),
          const SizedBox(height: 16),
          CheckoutFieldRow(
            left: CheckoutFormField(
              controller: controllers.postalCode,
              label: context.tr(
                'shop_checkout_postal_code',
                defaultText: 'Postal code',
              ),
            ),
            right: CheckoutFormField(
              controller: controllers.city,
              label: context.tr(
                'shop_checkout_city',
                defaultText: 'City',
              ),
            ),
          ),
          const SizedBox(height: 16),
          CheckoutFieldRow(
            left: CheckoutCountryField(
              controller: controllers.countryCode,
              countries: countries,
            ),
            right: CheckoutFormField(
              controller: controllers.province,
              label: context.tr(
                'shop_checkout_province',
                defaultText: 'State / Province',
              ),
              required: false,
            ),
          ),
          if (includePhone) ...[
            const SizedBox(height: 16),
            CheckoutFieldRow(
              left: CheckoutFormField(
                controller: controllers.phone,
                label: context.tr(
                  'shop_checkout_phone',
                  defaultText: 'Phone',
                ),
                keyboardType: TextInputType.phone,
                required: false,
              ),
              right: const SizedBox.shrink(),
            ),
          ],
        ],
      );
}
