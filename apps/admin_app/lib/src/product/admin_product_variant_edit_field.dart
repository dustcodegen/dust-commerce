part of 'admin_product_variant_edit_drawer.dart';

final class _AdminVariantTextField extends StatelessWidget {
  const _AdminVariantTextField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.optional = false,
  });

  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final String label;
  final bool optional;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            if (optional) ...[
              const SizedBox(width: 5),
              Text(
                '(Optional)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ]),
          const SizedBox(height: 7),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            validator: validator,
          ),
        ],
      );
}

String? _optionalIdentifier(String? value) =>
    (value?.trim().length ?? 0) > 255 ? 'Use at most 255 characters' : null;

String? _optionalNumber(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final number = double.tryParse(text);
  if (number == null) return 'Enter a number';
  return number < 0 ? 'Enter zero or a positive number' : null;
}

String? _requiredTitle(String? value) {
  final title = value?.trim() ?? '';
  if (title.isEmpty) return 'Enter a title';
  return title.length > 255 ? 'Use at most 255 characters' : null;
}
