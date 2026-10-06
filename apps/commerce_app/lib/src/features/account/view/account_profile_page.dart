import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_route_layout.dart';
import 'account_section.dart';
import 'profile_billing_address_editor.dart';
import 'profile_email_info.dart';
import 'profile_name_editor.dart';
import 'profile_phone_editor.dart';

/// Authenticated Medusa profile-information route.
@AppRoute('/account/profile', name: 'accountProfile', guards: [CustomerGuard])
final class AccountProfilePage extends StatefulWidget {
  /// Creates the profile page.
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final addresses = context.readAddressBookViewModel();
      if (addresses.state.status == AddressBookStatus.idle) {
        unawaited(addresses.load());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watchAccountViewModel().value;
    final addresses = context.watchAddressBookViewModel().value;
    final customer = account.customer;
    return StoreScaffold(
      body: customer == null
          ? const Center(child: CircularProgressIndicator())
          : AccountRouteLayout(
              customer: customer,
              state: account,
              active: AccountSection.profile,
              child: _ProfileContent(
                customer: customer,
                addresses: addresses,
              ),
            ),
    );
  }
}

final class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.customer, required this.addresses});

  final AddressBookState addresses;
  final Customer customer;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TranslatedText(
            'shop_account_profile',
            defaultText: 'Profile',
            style: const TextStyle(
              fontSize: 30,
              height: 48 / 30,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TranslatedText(
            'shop_account_profile_body',
            defaultText: 'View and update your profile information, including '
                'your name, email, and phone number. You can also update your '
                'billing address, or change your password.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          ProfileNameEditor(customer: customer),
          const _ProfileDivider(),
          ProfileEmailInfo(customer: customer),
          const _ProfileDivider(),
          ProfilePhoneEditor(customer: customer),
          const _ProfileDivider(),
          ProfileBillingAddressEditor(
            customer: customer,
            state: addresses,
          ),
        ],
      );
}

final class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Divider(),
      );
}
