import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Two account-address fields using Medusa's fixed compact grid.
final class CustomerAddressFieldPair extends StatelessWidget {
  /// Creates a two-column address-field row.
  const CustomerAddressFieldPair({
    required this.first,
    required this.second,
    this.firstWidth,
    super.key,
  });

  /// Leading field in source order.
  final Widget first;

  /// Optional fixed leading track, such as Medusa's 144px postal code.
  final double? firstWidth;

  /// Trailing field in source order.
  final Widget second;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (firstWidth case final width?)
            SizedBox(width: width, child: first)
          else
            Expanded(child: first),
          const SizedBox(width: 8),
          Expanded(child: second),
        ],
      );
}

/// One source-shaped field in an account address form.
final class CustomerAddressField extends StatelessWidget {
  /// Creates a customer-address field.
  const CustomerAddressField({
    required this.controller,
    required this.label,
    this.required = true,
    this.keyboardType,
    this.autofillHints,
    super.key,
  });

  /// Platform autofill values accepted by this field.
  final Iterable<String>? autofillHints;

  /// Text controller owned by the route-level dialog.
  final TextEditingController controller;

  /// Platform keyboard appropriate for this input.
  final TextInputType? keyboardType;

  /// Human-readable field label.
  final String label;

  /// Whether the field blocks submission when empty.
  final bool required;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        validator: required ? (value) => _required(context, value) : null,
        decoration: _decoration(label, required: required),
      );
}

/// Region-scoped country selector for an account address.
final class CustomerCountryField extends StatelessWidget {
  /// Creates a country selector from server-returned [countries].
  const CustomerCountryField({
    required this.controller,
    required this.countries,
    required this.label,
    super.key,
  });

  /// Region country codes in source order.
  final List<String> countries;

  /// Selected country controller owned by the route-level dialog.
  final TextEditingController controller;

  /// Human-readable country label.
  final String label;

  @override
  Widget build(BuildContext context) {
    final current = controller.text;
    final options = <String>{...countries, if (current.isNotEmpty) current};
    return Semantics(
      label: label,
      child: DropdownButtonFormField<String>(
        initialValue:
            options.contains(current) && current.isNotEmpty ? current : null,
        hint: const Text('Select...'),
        icon: const Icon(Icons.unfold_more, size: 20),
        items: [
          const DropdownMenuItem(value: '', child: Text('-')),
          for (final country in options)
            DropdownMenuItem(
                value: country, child: Text(country.toUpperCase())),
        ],
        onChanged:
            countries.isEmpty ? null : (value) => controller.text = value ?? '',
        validator: (value) => _required(context, value),
        decoration: _nativeSelectDecoration(),
      ),
    );
  }
}

String? _required(BuildContext context, String? value) =>
    value == null || value.trim().isEmpty
        ? context.tr(
            'shop_account_required',
            defaultText: 'This field is required.',
          )
        : null;

InputDecoration _decoration(String label, {bool required = true}) =>
    InputDecoration(
      label: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: label),
            if (required)
              const TextSpan(
                text: '*',
                style: TextStyle(color: StoreColors.rose),
              ),
          ],
        ),
      ),
      filled: true,
      fillColor: StoreColors.subtle,
      isDense: true,
      constraints: const BoxConstraints(minHeight: 44),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: StoreColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: StoreColors.interactive),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
    );

InputDecoration _nativeSelectDecoration() => InputDecoration(
      filled: true,
      fillColor: StoreColors.subtle,
      isDense: true,
      constraints: const BoxConstraints(minHeight: 44),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: StoreColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: StoreColors.interactive),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    );
