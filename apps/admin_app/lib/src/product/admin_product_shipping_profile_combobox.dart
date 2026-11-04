part of 'admin_product_shipping_profile_drawer.dart';

final class _ShippingProfileCombobox extends StatefulWidget {
  const _ShippingProfileCombobox({
    required this.page,
    required this.selected,
    required this.search,
    required this.busy,
    required this.loading,
    required this.onSearchChanged,
    required this.onSelect,
    required this.onLoadMore,
  });

  final bool busy;
  final bool loading;
  final VoidCallback onLoadMore;
  final ValueChanged<Option<AdminShippingProfile>> onSelect;
  final ValueChanged<String> onSearchChanged;
  final AdminShippingProfileList page;
  final TextEditingController search;
  final Option<AdminShippingProfile> selected;

  @override
  State<_ShippingProfileCombobox> createState() =>
      _ShippingProfileComboboxState();
}

final class _ShippingProfileComboboxState
    extends State<_ShippingProfileCombobox> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => MenuAnchor(
          controller: _menu,
          alignmentOffset: const Offset(0, 6),
          style: MenuStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            ),
          ),
          menuChildren: [
            SizedBox(
              width: constraints.maxWidth,
              height: _menuHeight,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: widget.search,
                    autofocus: true,
                    onChanged: widget.onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search shipping profiles',
                      prefixIcon: Icon(Icons.search_rounded, size: 18),
                    ),
                  ),
                ),
                if (widget.loading) const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final profile in widget.page.shippingProfiles)
                        ListTile(
                          dense: true,
                          selected: _selected(profile),
                          onTap: widget.busy ? null : () => _select(profile),
                          leading: Icon(
                            _selected(profile)
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            size: 17,
                            color: _selected(profile)
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                          ),
                          title: Text(profile.name),
                        ),
                      if (!widget.loading &&
                          widget.page.shippingProfiles.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('No shipping profiles found'),
                          ),
                        ),
                      if (!widget.loading &&
                          widget.page.shippingProfiles.length <
                              widget.page.count)
                        TextButton(
                          onPressed: widget.onLoadMore,
                          child: const Text('Load more'),
                        ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
          builder: (context, controller, child) => InkWell(
            borderRadius: BorderRadius.circular(7),
            onTap: widget.busy
                ? null
                : controller.isOpen
                    ? controller.close
                    : controller.open,
            child: InputDecorator(
              isEmpty: widget.selected is None<AdminShippingProfile>,
              decoration: InputDecoration(
                enabled: !widget.busy,
                suffixIcon: switch (widget.selected) {
                  Some() => IconButton(
                      tooltip: 'Clear shipping profile',
                      onPressed: widget.busy ? null : _clear,
                      icon: const Icon(Icons.close_rounded, size: 17),
                    ),
                  None() => const Icon(Icons.unfold_more_rounded, size: 17),
                },
              ),
              child: Text(_label),
            ),
          ),
        ),
      );

  double get _menuHeight =>
      58 + widget.page.shippingProfiles.length.clamp(1, 5) * 44;

  String get _label => switch (widget.selected) {
        Some(:final value) => value.name,
        None() => 'Select shipping profile',
      };

  bool _selected(AdminShippingProfile profile) => switch (widget.selected) {
        Some(:final value) => value.id == profile.id,
        None() => false,
      };

  void _clear() {
    widget.onSelect(const None());
    widget.search.clear();
    widget.onSearchChanged('');
  }

  void _select(AdminShippingProfile profile) {
    widget.onSelect(Some(profile));
    widget.search.clear();
    widget.onSearchChanged('');
    _menu.close();
  }
}
