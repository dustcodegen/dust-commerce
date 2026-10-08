import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'customer_address_controls.dart';
import 'customer_address_controllers.dart';

/// Medusa-shaped customer-address fields shared by profile and address book.
final class CustomerAddressForm extends StatelessWidget {
  /// Creates address fields bound to [controllers].
  const CustomerAddressForm({
    required this.controllers,
    required this.countries,
    this.profileBilling = false,
    super.key,
  });

  /// Active region country codes returned by the store API.
  final List<String> countries;

  /// Controllers that own this form's text.
  final CustomerAddressControllers controllers;

  /// Whether this form is rendered inside Medusa ProfileBillingAddress.
  final bool profileBilling;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          CustomerAddressFieldPair(
            first: CustomerAddressField(
              controller: controllers.firstName,
              label: context.tr(
                'shop_account_first_name',
                defaultText: 'First name',
              ),
              autofillHints: const [AutofillHints.givenName],
            ),
            second: CustomerAddressField(
              controller: controllers.lastName,
              label: context.tr(
                'shop_account_last_name',
                defaultText: 'Last name',
              ),
              autofillHints: const [AutofillHints.familyName],
            ),
          ),
          const SizedBox(height: 8),
          CustomerAddressField(
            controller: controllers.company,
            label: context.tr('shop_account_company', defaultText: 'Company'),
            required: false,
            autofillHints: const [AutofillHints.organizationName],
          ),
          const SizedBox(height: 8),
          if (profileBilling) ...[
            CustomerAddressField(
              controller: controllers.phone,
              label: context.tr('shop_account_phone', defaultText: 'Phone'),
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: 8),
          ],
          CustomerAddressField(
            controller: controllers.line1,
            label: context.tr('shop_account_address', defaultText: 'Address'),
            autofillHints: const [AutofillHints.streetAddressLine1],
          ),
          const SizedBox(height: 8),
          CustomerAddressField(
            controller: controllers.line2,
            label: context.tr(
              'shop_account_address_line_2',
              defaultText: 'Apartment, suite, etc.',
            ),
            required: false,
            autofillHints: const [AutofillHints.streetAddressLine2],
          ),
          const SizedBox(height: 8),
          CustomerAddressFieldPair(
            firstWidth: 144,
            first: CustomerAddressField(
              controller: controllers.postalCode,
              label: context.tr(
                'shop_account_postal_code',
                defaultText: 'Postal code',
              ),
              autofillHints: const [AutofillHints.postalCode],
            ),
            second: CustomerAddressField(
              controller: controllers.city,
              label: context.tr('shop_account_city', defaultText: 'City'),
              autofillHints: const [AutofillHints.addressCity],
            ),
          ),
          const SizedBox(height: 8),
          CustomerAddressField(
            controller: controllers.province,
            label: context.tr(
              'shop_account_province',
              defaultText: profileBilling ? 'Province' : 'Province / State',
            ),
            required: false,
            autofillHints: const [AutofillHints.addressState],
          ),
          const SizedBox(height: 8),
          CustomerCountryField(
            controller: controllers.countryCode,
            countries: countries,
            label: context.tr(
              'shop_account_country',
              defaultText: 'Country',
            ),
          ),
          if (!profileBilling) ...[
            const SizedBox(height: 8),
            CustomerAddressField(
              controller: controllers.phone,
              label: context.tr('shop_account_phone', defaultText: 'Phone'),
              required: false,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
          ],
        ],
      );
}
