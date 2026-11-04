part of 'admin_product_stock_page.dart';

final class _AdminProductStockBody extends StatelessWidget {
  const _AdminProductStockBody({
    required this.busy,
    required this.drafts,
    required this.failure,
    required this.formKey,
    required this.onManagedChanged,
  });

  final bool busy;
  final List<_StockDraft> drafts;
  final Option<String> failure;
  final GlobalKey<FormState> formKey;
  final void Function(_StockDraft draft, {required bool managed})
      onManagedChanged;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Product stock',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage aggregate sellable stock for each variant.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _AdminProductStockGrid(
                        busy: busy,
                        drafts: drafts,
                        onManagedChanged: onManagedChanged,
                      ),
                      if (failure case Some(value: final message)) ...[
                        const SizedBox(height: 16),
                        _AdminProductStockFailure(message: message),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

final class _AdminProductStockGrid extends StatelessWidget {
  const _AdminProductStockGrid({
    required this.busy,
    required this.drafts,
    required this.onManagedChanged,
  });

  final bool busy;
  final List<_StockDraft> drafts;
  final void Function(_StockDraft draft, {required bool managed})
      onManagedChanged;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth.clamp(620, 900),
              child: Column(children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  child: const Row(children: [
                    Expanded(flex: 3, child: Text('Title')),
                    Expanded(flex: 2, child: Text('SKU')),
                    SizedBox(width: 120, child: Text('Managed')),
                    SizedBox(width: 150, child: Text('Stock')),
                  ]),
                ),
                for (final draft in drafts)
                  _AdminProductStockRow(
                    busy: busy,
                    draft: draft,
                    onManagedChanged: onManagedChanged,
                  ),
              ]),
            ),
          ),
        ),
      );
}

final class _AdminProductStockRow extends StatelessWidget {
  const _AdminProductStockRow({
    required this.busy,
    required this.draft,
    required this.onManagedChanged,
  });

  final bool busy;
  final _StockDraft draft;
  final void Function(_StockDraft draft, {required bool managed})
      onManagedChanged;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(children: [
          Expanded(flex: 3, child: Text(draft.variant.title)),
          Expanded(flex: 2, child: Text(draft.variant.sku ?? '—')),
          SizedBox(
            width: 120,
            child: Switch(
              value: draft.managed,
              onChanged: busy
                  ? null
                  : (value) => onManagedChanged(draft, managed: value),
            ),
          ),
          SizedBox(
            width: 150,
            child: TextFormField(
              key: ValueKey('variant-stock-${draft.variant.id}'),
              controller: draft.quantity,
              enabled: !busy,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
              validator: _validateStock,
            ),
          ),
        ]),
      );
}

String? _validateStock(String? value) {
  final quantity = int.tryParse(value ?? '');
  return quantity == null || quantity < 0 ? 'Enter valid stock' : null;
}
