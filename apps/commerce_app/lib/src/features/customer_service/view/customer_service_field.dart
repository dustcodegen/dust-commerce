import 'package:flutter/material.dart';

/// One consistently sized field in the Store support form.
final class CustomerServiceField extends StatelessWidget {
  /// Creates a bounded text field.
  const CustomerServiceField({
    required this.controller,
    required this.label,
    required this.enabled,
    required this.validator,
    this.autofillHints,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    super.key,
  });

  /// Browser autofill hints for contact identity fields.
  final Iterable<String>? autofillHints;

  /// Form-owned text controller.
  final TextEditingController controller;

  /// Whether editing is available while no request is pending.
  final bool enabled;

  /// Platform keyboard appropriate for the field.
  final TextInputType? keyboardType;

  /// Visible field label.
  final String label;

  /// Maximum accepted character count.
  final int? maxLength;

  /// Maximum visible lines.
  final int? maxLines;

  /// Minimum visible lines.
  final int? minLines;

  /// Platform keyboard action.
  final TextInputAction? textInputAction;

  /// Immediate customer-facing validation.
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        enabled: enabled,
        autofillHints: autofillHints,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: minLines,
        textInputAction: textInputAction,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: (minLines ?? 1) > 1,
          border: const OutlineInputBorder(),
        ),
      );
}
