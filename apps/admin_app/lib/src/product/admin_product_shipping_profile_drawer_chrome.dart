part of 'admin_product_shipping_profile_drawer.dart';

final class _ShippingProfileDrawerFrame extends StatelessWidget {
  const _ShippingProfileDrawerFrame({
    required this.page,
    required this.selected,
    required this.search,
    required this.failure,
    required this.busy,
    required this.loading,
    required this.onClose,
    required this.onSearchChanged,
    required this.onSelect,
    required this.onLoadMore,
    required this.onSave,
  });

  final bool busy;
  final Option<String> failure;
  final bool loading;
  final VoidCallback onClose;
  final VoidCallback onLoadMore;
  final VoidCallback onSave;
  final ValueChanged<Option<AdminShippingProfile>> onSelect;
  final ValueChanged<String> onSearchChanged;
  final AdminShippingProfileList page;
  final TextEditingController search;
  final Option<AdminShippingProfile> selected;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 16,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width.clamp(0, 560).toDouble(),
          height: double.infinity,
          child: Column(children: [
            _ShippingProfileDrawerHeader(busy: busy, onClose: onClose),
            Expanded(
              child: _ShippingProfileDrawerBody(
                page: page,
                selected: selected,
                search: search,
                failure: failure,
                busy: busy,
                loading: loading,
                onSearchChanged: onSearchChanged,
                onSelect: onSelect,
                onLoadMore: onLoadMore,
              ),
            ),
            _ShippingProfileDrawerFooter(
              busy: busy,
              onCancel: onClose,
              onSave: onSave,
            ),
          ]),
        ),
      );
}

final class _ShippingProfileDrawerHeader extends StatelessWidget {
  const _ShippingProfileDrawerHeader({
    required this.busy,
    required this.onClose,
  });

  final bool busy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Container(
        height: 62,
        padding: const EdgeInsets.only(left: 24, right: 12),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              'Shipping Configuration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: busy ? null : onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ]),
      );
}

final class _ShippingProfileDrawerFooter extends StatelessWidget {
  const _ShippingProfileDrawerFooter({
    required this.busy,
    required this.onCancel,
    required this.onSave,
  });

  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
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
