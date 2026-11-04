import 'package:flutter/material.dart';

/// Responsive five-field grid copied from Medusa's customer-create source.
final class AdminCustomerCreateFields extends StatelessWidget {
  /// Creates the allowlisted customer field grid.
  const AdminCustomerCreateFields({
    required this.company,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.enabled,
    super.key,
  });

  /// Optional company input.
  final TextEditingController company;

  /// Required email input.
  final TextEditingController email;

  /// Whether fields accept edits.
  final bool enabled;

  /// Optional given-name input.
  final TextEditingController firstName;

  /// Optional family-name input.
  final TextEditingController lastName;

  /// Optional contact-number input.
  final TextEditingController phone;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth >= 600
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              AdminCustomerCreateField(
                width: width,
                label: 'First name',
                controller: firstName,
                enabled: enabled,
              ),
              AdminCustomerCreateField(
                width: width,
                label: 'Last name',
                controller: lastName,
                enabled: enabled,
              ),
              AdminCustomerCreateField(
                width: width,
                label: 'Email',
                controller: email,
                enabled: enabled,
                required: true,
                validator: _emailError,
              ),
              AdminCustomerCreateField(
                width: width,
                label: 'Company',
                controller: company,
                enabled: enabled,
              ),
              AdminCustomerCreateField(
                width: width,
                label: 'Phone',
                controller: phone,
                enabled: enabled,
              ),
            ],
          );
        },
      );
}

/// One labeled input with Medusa's optional-label treatment.
final class AdminCustomerCreateField extends StatelessWidget {
  /// Creates one focused customer input.
  const AdminCustomerCreateField({
    required this.width,
    required this.label,
    required this.controller,
    required this.enabled,
    this.required = false,
    this.validator,
    super.key,
  });

  /// Text controller owned by the parent form.
  final TextEditingController controller;

  /// Whether the field accepts edits.
  final bool enabled;

  /// Visible field name.
  final String label;

  /// Whether the field omits Medusa's optional suffix.
  final bool required;

  /// Optional field validation.
  final FormFieldValidator<String>? validator;

  /// Responsive grid width.
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            if (!required) ...[
              const SizedBox(width: 4),
              Text(
                '(optional)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ]),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            validator: validator,
            keyboardType: required ? TextInputType.emailAddress : null,
            autofillHints: const [],
          ),
        ]),
      );
}

String? _emailError(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty || !email.contains('@') || email.endsWith('@')) {
    return 'Enter a valid email';
  }
  return null;
}
