part of 'admin_product_variant_edit_drawer.dart';

final class _AdminVariantInventorySection extends StatelessWidget {
  const _AdminVariantInventorySection({
    required this.allowBackorder,
    required this.busy,
    required this.manageInventory,
    required this.onAllowBackorderChanged,
    required this.onManageInventoryChanged,
    required this.values,
  });

  final bool allowBackorder;
  final bool busy;
  final bool manageInventory;
  final ValueChanged<bool> onAllowBackorderChanged;
  final ValueChanged<bool> onManageInventoryChanged;
  final _VariantEditValues values;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Stock & Inventory',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _AdminVariantTextField(
            controller: values.sku,
            enabled: !busy,
            label: 'SKU',
            optional: true,
            validator: _optionalIdentifier,
          ),
          const SizedBox(height: 16),
          _AdminVariantTextField(
            controller: values.ean,
            enabled: !busy,
            label: 'EAN',
            optional: true,
            validator: _optionalIdentifier,
          ),
          const SizedBox(height: 16),
          _AdminVariantTextField(
            controller: values.upc,
            enabled: !busy,
            label: 'UPC',
            optional: true,
            validator: _optionalIdentifier,
          ),
          const SizedBox(height: 16),
          _AdminVariantTextField(
            controller: values.barcode,
            enabled: !busy,
            label: 'Barcode',
            optional: true,
            validator: _optionalIdentifier,
          ),
          const SizedBox(height: 28),
          _AdminVariantPolicy(
            busy: busy,
            hint: "When enabled, we'll change the inventory quantity for you "
                'when orders and returns are created.',
            onChanged: onManageInventoryChanged,
            title: 'Manage inventory',
            value: manageInventory,
          ),
          const SizedBox(height: 8),
          _AdminVariantPolicy(
            busy: busy,
            hint: 'When enabled, customers can purchase the variant even if '
                "there's no available quantity.",
            onChanged: onAllowBackorderChanged,
            title: 'Allow backorders',
            value: allowBackorder,
          ),
        ],
      );
}

final class _AdminVariantPolicy extends StatelessWidget {
  const _AdminVariantPolicy({
    required this.busy,
    required this.hint,
    required this.onChanged,
    required this.title,
    required this.value,
  });

  final bool busy;
  final String hint;
  final ValueChanged<bool> onChanged;
  final String title;
  final bool value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 22,
            child: Row(children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              SizedBox(
                width: 36,
                height: 22,
                child: FittedBox(
                  child: Switch(
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF3B82F6),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFE4E4E7),
                    onChanged: busy ? null : onChanged,
                    trackOutlineColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    value: value,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.25,
                ),
          ),
        ],
      );
}
