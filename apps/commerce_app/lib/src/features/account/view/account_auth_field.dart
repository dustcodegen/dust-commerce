import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// One dense source-shaped field in the public account form.
final class AccountAuthField extends StatelessWidget {
  /// Creates a labelled account field.
  const AccountAuthField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.autofillHints,
    this.validator,
    this.suffixIcon,
    this.obscureText = false,
    this.required = true,
    super.key,
  });

  /// Platform autofill values accepted by this field.
  final Iterable<String>? autofillHints;

  /// Text controller owned by the route-level form.
  final TextEditingController controller;

  /// Platform keyboard appropriate for the input.
  final TextInputType? keyboardType;

  /// Human-readable field label.
  final String label;

  /// Whether the input should hide its value.
  final bool obscureText;

  /// Whether to render the source required marker.
  final bool required;

  /// Optional trailing field action.
  final Widget? suffixIcon;

  /// Form-specific validation owned by the parent form.
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        validator: validator,
        obscureText: obscureText,
        obscuringCharacter: '•',
        decoration: InputDecoration(
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
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 44,
          ),
          filled: true,
          fillColor: StoreColors.subtle,
          isDense: true,
          constraints: const BoxConstraints(minHeight: 44),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: StoreColors.border),
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        ),
      );
}
