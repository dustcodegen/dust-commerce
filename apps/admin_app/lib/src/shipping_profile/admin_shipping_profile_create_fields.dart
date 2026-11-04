import 'package:flutter/material.dart';

/// Responsive two-column name and type inputs.
final class AdminShippingProfileCreateFields extends StatelessWidget {
  /// Creates required profile inputs.
  const AdminShippingProfileCreateFields({
    required this.name,
    required this.type,
    required this.busy,
    required this.validator,
    required this.onSubmitted,
    super.key,
  });

  /// Whether inputs are disabled.
  final bool busy;

  /// Merchant-facing name input.
  final TextEditingController name;

  /// Submits from the keyboard.
  final VoidCallback onSubmitted;

  /// Fulfillment behavior type input.
  final TextEditingController type;

  /// Shared required-field validation.
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 560) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _AdminShippingProfileField(
                    label: 'Name',
                    controller: name,
                    busy: busy,
                    autofocus: true,
                    validator: validator,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AdminShippingProfileField(
                    label: 'Type',
                    tooltip: 'Enter shipping profile type, for example: '
                        'Heavy, Oversized, Freight-only, etc.',
                    controller: type,
                    busy: busy,
                    validator: validator,
                    onSubmitted: onSubmitted,
                  ),
                ),
              ],
            );
          }
          return Column(children: [
            _AdminShippingProfileField(
              label: 'Name',
              controller: name,
              busy: busy,
              autofocus: true,
              validator: validator,
            ),
            const SizedBox(height: 16),
            _AdminShippingProfileField(
              label: 'Type',
              tooltip: 'Enter shipping profile type, for example: Heavy, '
                  'Oversized, Freight-only, etc.',
              controller: type,
              busy: busy,
              validator: validator,
              onSubmitted: onSubmitted,
            ),
          ]);
        },
      );
}

final class _AdminShippingProfileField extends StatelessWidget {
  const _AdminShippingProfileField({
    required this.label,
    required this.controller,
    required this.busy,
    required this.validator,
    this.autofocus = false,
    this.tooltip,
    this.onSubmitted,
  });

  final bool autofocus;
  final bool busy;
  final TextEditingController controller;
  final String label;
  final VoidCallback? onSubmitted;
  final String? tooltip;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            if (tooltip case final value?) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: value,
                child: const Icon(Icons.info_outline_rounded, size: 14),
              ),
            ],
          ]),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            autofocus: autofocus,
            enabled: !busy,
            validator: validator,
            onFieldSubmitted:
                onSubmitted == null ? null : (_) => onSubmitted!(),
          ),
        ],
      );
}
