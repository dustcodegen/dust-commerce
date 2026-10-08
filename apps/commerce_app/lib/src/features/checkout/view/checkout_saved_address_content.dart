import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_radio_mark.dart';

/// Greeting and source-shaped selector for usable saved addresses.
final class CheckoutSavedAddressContent extends StatelessWidget {
  /// Creates saved-address content.
  const CheckoutSavedAddressContent({
    required this.addresses,
    required this.customer,
    required this.draft,
    required this.onSelected,
    super.key,
  });

  /// Region-compatible customer addresses.
  final List<CustomerAddressView> addresses;

  /// Customer named in the greeting.
  final Customer customer;

  /// Current form values used to mark the selected address.
  final CheckoutAddressDraft draft;

  /// Copies one address into the form.
  final ValueChanged<CustomerAddressView> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = addresses
        .where(draft.matchesSavedAddress)
        .map((address) => address.id)
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.tr(
          'shop_checkout_saved_address_prompt',
          defaultText:
              'Hi {name}, do you want to use one of your saved addresses?',
          args: {'name': _greetingName},
        )),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey(selected),
          initialValue: selected,
          isExpanded: true,
          itemHeight: null,
          menuMaxHeight: 320,
          style: _savedAddressTextStyle,
          icon: const Icon(Icons.unfold_more, size: 20),
          borderRadius: BorderRadius.circular(8),
          dropdownColor: StoreColors.base,
          decoration: _savedAddressSelectDecoration,
          hint: const TranslatedText(
            'shop_checkout_choose_saved_address',
            defaultText: 'Choose an address',
            style: _savedAddressTextStyle,
          ),
          selectedItemBuilder: (_) => [
            for (final address in addresses)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  address.line1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          items: [
            for (final address in addresses)
              DropdownMenuItem(
                value: address.id,
                child: _SavedAddressOption(
                  address: address,
                  selected: address.id == selected,
                ),
              ),
          ],
          onChanged: (id) {
            for (final address in addresses) {
              if (address.id == id) return onSelected(address);
            }
          },
        ),
      ],
    );
  }

  String get _greetingName {
    final firstName = customer.firstName?.trim();
    return firstName == null || firstName.isEmpty
        ? customer.displayName
        : firstName;
  }
}

final class _SavedAddressOption extends StatelessWidget {
  const _SavedAddressOption({required this.address, required this.selected});

  final CustomerAddressView address;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckoutRadioMark(selected: selected),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${address.firstName} ${address.lastName}',
                    style: _savedAddressNameStyle,
                  ),
                  if (address.company case final company?)
                    Text(company, style: _savedAddressCompanyStyle),
                  const SizedBox(height: 8),
                  DefaultTextStyle(
                    style: _savedAddressTextStyle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${address.line1}${_line2(address.line2)}'),
                        Text('${address.postalCode}, ${address.city}'),
                        Text(
                          '${_province(address.province)}'
                          '${address.countryCode.toUpperCase()}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  static String _line2(String? value) => value == null ? '' : ', $value';

  static String _province(String? value) => value == null ? '' : '$value, ';
}

const _savedAddressCompanyStyle = TextStyle(fontSize: 12, height: 20 / 12);

const _savedAddressSelectDecoration = InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: StoreColors.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: StoreColors.borderStrong),
  ),
);

const _savedAddressNameStyle = TextStyle(
  fontSize: 16,
  height: 24 / 16,
  fontWeight: FontWeight.w600,
);

const _savedAddressTextStyle = TextStyle(
  color: StoreColors.foreground,
  fontSize: 16,
  height: 24 / 16,
);
