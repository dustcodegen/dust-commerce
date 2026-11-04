part of 'admin_product_image_variants_drawer.dart';

final class _ImageVariantsTable extends StatelessWidget {
  const _ImageVariantsTable({
    required this.variants,
    required this.selected,
    required this.enabled,
    required this.onChanged,
    required this.onToggleAll,
  });

  final bool enabled;
  final ValueChanged<bool> onToggleAll;
  final void Function(String id, {required bool selected}) onChanged;
  final Set<String> selected;
  final List<AdminProductVariant> variants;

  @override
  Widget build(BuildContext context) {
    final selectedCount =
        variants.where((item) => selected.contains(item.id)).length;
    final allSelected = variants.isNotEmpty && selectedCount == variants.length;
    return Column(
      children: [
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Row(
            children: [
              Checkbox(
                tristate: true,
                value: selectedCount == 0
                    ? false
                    : allSelected
                        ? true
                        : null,
                onChanged: enabled ? (_) => onToggleAll(!allSelected) : null,
              ),
              const Expanded(flex: 3, child: Text('Title')),
              const Expanded(flex: 2, child: Text('SKU')),
              const Expanded(flex: 2, child: Text('Thumbnail')),
            ],
          ),
        ),
        Expanded(
          child: variants.isEmpty
              ? const Center(child: Text('No variants found'))
              : ListView.builder(
                  itemCount: variants.length,
                  itemBuilder: (context, index) {
                    final variant = variants[index];
                    return _ImageVariantRow(
                      variant: variant,
                      selected: selected.contains(variant.id),
                      enabled: enabled,
                      onChanged: (value) =>
                          onChanged(variant.id, selected: value),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

final class _ImageVariantRow extends StatelessWidget {
  const _ImageVariantRow({
    required this.variant,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool selected;
  final AdminProductVariant variant;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: enabled ? (value) => onChanged(value ?? false) : null,
            ),
            Expanded(flex: 3, child: Text(variant.title)),
            Expanded(flex: 2, child: Text(variant.sku ?? '—')),
            const Expanded(flex: 2, child: Text('Not configured')),
          ],
        ),
      );
}
