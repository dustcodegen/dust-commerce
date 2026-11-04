part of 'admin_product_shipping_profile_drawer.dart';

final class _ShippingProfileDrawerBody extends StatelessWidget {
  const _ShippingProfileDrawerBody({
    required this.page,
    required this.selected,
    required this.search,
    required this.failure,
    required this.busy,
    required this.loading,
    required this.onSearchChanged,
    required this.onSelect,
    required this.onLoadMore,
  });

  final bool busy;
  final Option<String> failure;
  final bool loading;
  final VoidCallback onLoadMore;
  final ValueChanged<Option<AdminShippingProfile>> onSelect;
  final ValueChanged<String> onSearchChanged;
  final AdminShippingProfileList page;
  final TextEditingController search;
  final Option<AdminShippingProfile> selected;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Shipping Profile',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          _ShippingProfileCombobox(
            page: page,
            selected: selected,
            search: search,
            busy: busy,
            loading: loading,
            onSearchChanged: onSearchChanged,
            onSelect: onSelect,
            onLoadMore: onLoadMore,
          ),
          if (failure case Some(value: final message)) ...[
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      );
}
