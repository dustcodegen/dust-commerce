import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_saved_address_content.dart';

/// Medusa saved-address prompt adapted to the separately loaded address book.
final class CheckoutSavedAddressSelector extends StatelessWidget {
  /// Creates a region-scoped saved-address control.
  const CheckoutSavedAddressSelector({
    required this.customer,
    required this.state,
    required this.countries,
    required this.draft,
    required this.onSelected,
    super.key,
  });

  /// Region country codes accepted by this cart.
  final List<String> countries;

  /// Customer named in the source greeting.
  final Customer customer;

  /// Current editable shipping form used to identify the selected address.
  final CheckoutAddressDraft draft;

  /// Copies the selected saved address into the editable form.
  final ValueChanged<CustomerAddressView> onSelected;

  /// Address-book request and data state.
  final AddressBookState state;

  @override
  Widget build(BuildContext context) {
    final addresses = state.shippingAddressesFor(countries);
    if (addresses.isEmpty && state.status == AddressBookStatus.ready) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StoreColors.base,
        borderRadius: BorderRadius.circular(8),
      ),
      child: switch (state.status) {
        AddressBookStatus.idle ||
        AddressBookStatus.loading =>
          const LinearProgressIndicator(minHeight: 2),
        AddressBookStatus.failed when addresses.isEmpty =>
          const _SavedAddressFailure(),
        _ => CheckoutSavedAddressContent(
            addresses: addresses,
            customer: customer,
            draft: draft,
            onSelected: onSelected,
          ),
      },
    );
  }
}

final class _SavedAddressFailure extends StatelessWidget {
  const _SavedAddressFailure();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              context.tr(
                'shop_checkout_saved_addresses_unavailable',
                defaultText:
                    'Saved addresses are unavailable. Enter one below.',
              ),
              style: const TextStyle(color: StoreColors.foregroundSubtle),
            ),
          ),
          TextButton(
            onPressed: context.readAddressBookViewModel().load,
            child: const TranslatedText('shop_retry', defaultText: 'Try again'),
          ),
        ],
      );
}
