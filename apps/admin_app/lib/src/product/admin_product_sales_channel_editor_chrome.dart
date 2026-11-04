part of 'admin_product_sales_channel_editor.dart';

final class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.busy, required this.onClose});

  final bool busy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(
            tooltip: 'Close',
            onPressed: busy ? null : onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ]),
      );
}

final class _EditorFooter extends StatelessWidget {
  const _EditorFooter({
    required this.busy,
    required this.onCancel,
    required this.onSave,
  });

  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: busy ? null : onCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: busy ? null : onSave,
            child: busy
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ]),
      );
}

final class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.busy,
    required this.loading,
    required this.page,
    required this.selected,
    required this.failure,
    required this.search,
    required this.horizontal,
    required this.onSearchChanged,
    required this.onToggle,
    required this.onTogglePage,
    required this.onPage,
  });

  final bool busy;
  final Option<String> failure;
  final ScrollController horizontal;
  final bool loading;
  final ValueChanged<int> onPage;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onToggle;
  final ValueChanged<bool> onTogglePage;
  final AdminSalesChannelDetailList page;
  final TextEditingController search;
  final Set<String> selected;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 320,
                child: TextField(
                  controller: search,
                  autofocus: true,
                  enabled: !busy,
                  onChanged: onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.zero,
                child: Column(children: [
                  if (loading) const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: _SalesChannelTable(
                      page: page,
                      selected: selected,
                      busy: busy,
                      loading: loading,
                      horizontal: horizontal,
                      onToggle: onToggle,
                      onTogglePage: onTogglePage,
                    ),
                  ),
                  _SalesChannelPagination(
                    page: page,
                    busy: busy || loading,
                    onPage: onPage,
                  ),
                ]),
              ),
            ),
            if (failure case Some(value: final message)) ...[
              const SizedBox(height: 12),
              _SalesChannelFailure(message),
            ],
          ]),
        ),
      );
}
