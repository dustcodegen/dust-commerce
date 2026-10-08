import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// One required input shared by Medusa-shaped profile editors.
final class ProfileEditorField extends StatelessWidget {
  /// Creates a profile editor input.
  const ProfileEditorField({
    required this.controller,
    required this.label,
    required this.validator,
    this.autofillHints,
    this.obscureText = false,
    this.width,
    super.key,
  });

  /// Platform autofill values accepted by this input.
  final Iterable<String>? autofillHints;

  /// Text controller owned by the profile editor.
  final TextEditingController controller;

  /// Human-readable field label.
  final String label;

  /// Whether the field should hide its value.
  final bool obscureText;

  /// Validation owned by the profile operation.
  final String? Function(String?) validator;

  /// Optional width used by the wrapping password grid.
  final double? width;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      borderSide: BorderSide(color: StoreColors.border),
    );
    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      autofillHints: autofillHints,
      validator: validator,
      style: const TextStyle(fontSize: 14, height: 20 / 14),
      decoration: InputDecoration(
        labelText: '$label *',
        filled: true,
        fillColor: StoreColors.base,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: StoreColors.foreground),
        ),
      ),
    );
    return width == null ? field : SizedBox(width: width, child: field);
  }
}
