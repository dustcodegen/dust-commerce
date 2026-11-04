part of 'admin_product_create_page.dart';

final class _VariantCard extends StatefulWidget {
  const _VariantCard({required this.draft, required this.currencies});

  final List<String> currencies;
  final _VariantDraft draft;

  @override
  State<_VariantCard> createState() => _VariantCardState();
}

final class _VariantCardState extends State<_VariantCard> {
  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(draft.value, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _compactField('SKU', draft.sku, width: 180),
                _compactField(
                  'Inventory',
                  draft.inventory,
                  width: 120,
                  enabled: draft.manageInventory,
                ),
                for (final currency in widget.currencies)
                  _compactField(
                    '${currency.toUpperCase()} price',
                    draft.prices[currency]!,
                    width: 140,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Manage inventory'),
                  value: draft.manageInventory,
                  onChanged: (value) => setState(() {
                    draft.manageInventory = value ?? false;
                  }),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Allow backorders'),
                  value: draft.allowBackorder,
                  onChanged: (value) => setState(() {
                    draft.allowBackorder = value ?? false;
                  }),
                ),
              ].map((child) => SizedBox(width: 210, child: child)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactField(
    String label,
    TextEditingController controller, {
    required double width,
    bool enabled = true,
  }) =>
      SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            TextField(controller: controller, enabled: enabled),
          ],
        ),
      );
}

final class _VariantDraft {
  _VariantDraft(this.selections);

  Map<String, String> selections;
  final sku = TextEditingController();
  final inventory = TextEditingController(text: '0');
  final prices = <String, TextEditingController>{};
  var manageInventory = false;
  var allowBackorder = false;

  String get value => productOptionPermutationTitle(selections);

  static String keyFor(Map<String, String> selections) =>
      selections.values.map((value) => '${value.length}:$value').join();

  void ensureCurrencies(List<String> currencies) {
    for (final currency in currencies) {
      prices.putIfAbsent(currency, TextEditingController.new);
    }
  }

  void dispose() {
    sku.dispose();
    inventory.dispose();
    for (final controller in prices.values) {
      controller.dispose();
    }
  }
}
