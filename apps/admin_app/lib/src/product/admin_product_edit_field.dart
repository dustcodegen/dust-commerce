part of 'admin_product_edit_drawer.dart';

final class _AdminProductEditField extends StatelessWidget {
  const _AdminProductEditField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.validator,
    this.maxLines = 1,
    this.optional = false,
    this.prefix,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final int maxLines;
  final bool optional;
  final Widget? prefix;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdminProductEditLabel(text: label, optional: optional),
          const SizedBox(height: 7),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: controller,
            decoration: InputDecoration(prefixIcon: prefix),
            enabled: enabled,
            maxLines: maxLines,
            validator: validator,
          ),
        ],
      );
}

final class _AdminProductEditLabel extends StatelessWidget {
  const _AdminProductEditLabel({
    required this.text,
    this.optional = false,
  });

  final bool optional;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text, style: Theme.of(context).textTheme.labelLarge),
          if (optional) ...[
            const SizedBox(width: 5),
            Text(
              'Optional',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      );
}
