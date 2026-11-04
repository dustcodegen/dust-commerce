part of 'admin_product_create_page.dart';

extension on _AdminProductCreatePageState {
  Widget _variantEditor(AdminProductCreateState state) => Column(
        key: const ValueKey('variants'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Variants', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Set inventory and regional pricing for every sellable variant.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          for (final variant in _variants) ...[
            _VariantCard(
              draft: variant,
              currencies: state.currencyCodes,
            ),
            const SizedBox(height: 12),
          ],
          _failure(state),
        ],
      );

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool optional = false,
    int maxLines = 1,
    Widget? prefix,
    String? helper,
    ValueChanged<String>? onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
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
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(prefixIcon: prefix, helperText: helper),
            validator: validator,
          ),
        ],
      );

  Widget _failure(AdminProductCreateState state) => switch (state.failure) {
        Some(:final value) => Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(value),
            ),
          ),
        None() => const SizedBox.shrink(),
      };
}
