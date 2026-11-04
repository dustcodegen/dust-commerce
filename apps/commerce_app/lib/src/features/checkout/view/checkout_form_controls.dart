import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Two equal checkout controls separated by the source 16px gutter.
final class CheckoutFieldRow extends StatelessWidget {
  /// Creates a checkout field row.
  const CheckoutFieldRow({required this.left, required this.right, super.key});

  /// Control rendered in the first column.
  final Widget left;

  /// Control rendered in the second column.
  final Widget right;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 16),
          Expanded(child: right),
        ],
      );
}

/// Labelled checkout text field with shared validation and source styling.
final class CheckoutFormField extends StatelessWidget {
  /// Creates a checkout text field.
  const CheckoutFormField({
    required this.controller,
    required this.label,
    this.required = true,
    this.keyboardType,
    super.key,
  });

  /// Owns the editable value.
  final TextEditingController controller;

  /// Selects the platform keyboard.
  final TextInputType? keyboardType;

  /// Customer-facing floating label.
  final String label;

  /// Whether an empty value blocks address submission.
  final bool required;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: checkoutFieldTextStyle,
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                ? context.tr(
                    'shop_checkout_required',
                    defaultText: 'This field is required.',
                  )
                : null
            : null,
        decoration: checkoutFieldDecoration(label, required: required),
      );
}

/// Region-owned country selector for checkout addresses.
final class CheckoutCountryField extends StatelessWidget {
  /// Creates a country selector.
  const CheckoutCountryField({
    required this.controller,
    required this.countries,
    super.key,
  });

  /// Region country codes offered by the server.
  final List<String> countries;

  /// Owns the selected country code.
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        initialValue:
            countries.contains(controller.text) ? controller.text : null,
        icon: const Icon(Icons.unfold_more, size: 16),
        style: checkoutFieldTextStyle,
        items: [
          for (final country in countries)
            DropdownMenuItem(
              value: country,
              child: Text(countryName(context, country)),
            ),
        ],
        onChanged: (value) => controller.text = value ?? '',
        validator: (value) => value == null
            ? context.tr(
                'shop_checkout_choose_country',
                defaultText: 'Choose a country.',
              )
            : null,
        hint: Text(
          context.tr('shop_checkout_country', defaultText: 'Country'),
        ),
        decoration: checkoutFieldDecoration(null),
      );
}

/// Source-shaped 44px checkout input decoration.
InputDecoration checkoutFieldDecoration(
  String? label, {
  bool required = false,
}) =>
    InputDecoration(
      label: label == null
          ? null
          : Text.rich(TextSpan(children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: StoreColors.rose),
                ),
            ])),
      filled: true,
      fillColor: StoreColors.subtle,
      isDense: true,
      constraints: const BoxConstraints(minHeight: 44),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: StoreColors.border),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    );

/// Source `txt-compact-medium` size used inside checkout form controls.
const checkoutFieldTextStyle = TextStyle(fontSize: 14, height: 20 / 14);
