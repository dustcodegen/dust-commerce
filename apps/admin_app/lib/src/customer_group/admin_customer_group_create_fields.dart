import 'package:flutter/material.dart';

/// Name field laid out like Medusa's two-column customer-group form grid.
final class AdminCustomerGroupCreateFields extends StatelessWidget {
  /// Creates the single supported Medusa form field.
  const AdminCustomerGroupCreateFields({
    required this.name,
    required this.enabled,
    required this.onSubmit,
    super.key,
  });

  /// Whether input can be edited.
  final bool enabled;

  /// Merchant-facing customer-group name.
  final TextEditingController name;

  /// Submits the enclosing form.
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final field = _AdminCustomerGroupNameField(
            controller: name,
            enabled: enabled,
            onSubmit: onSubmit,
          );
          if (constraints.maxWidth < 560) return field;
          return Row(children: [
            Expanded(child: field),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox.shrink()),
          ]);
        },
      );
}

final class _AdminCustomerGroupNameField extends StatelessWidget {
  const _AdminCustomerGroupNameField({
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Name', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            autofocus: true,
            enabled: enabled,
            validator: _validateCustomerGroupName,
            onFieldSubmitted: (_) => onSubmit(),
          ),
        ],
      );
}

String? _validateCustomerGroupName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Name is required';
  if (name.length > 255) return 'Use at most 255 characters';
  return null;
}
