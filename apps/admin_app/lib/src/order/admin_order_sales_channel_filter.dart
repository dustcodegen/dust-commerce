part of 'admin_order_toolbar.dart';

final class _SalesChannelFilterSubmenu extends StatelessWidget {
  const _SalesChannelFilterSubmenu({
    required this.salesChannels,
    required this.selected,
    required this.onChanged,
  });

  final ValueChanged<List<String>> onChanged;
  final List<AdminSalesChannel> salesChannels;
  final List<String> selected;

  @override
  Widget build(BuildContext context) => SubmenuButton(
        menuStyle: _regionMenuStyle(context),
        submenuIcon: const WidgetStatePropertyAll(SizedBox.shrink()),
        menuChildren: [
          _SalesChannelChoices(
            salesChannels: salesChannels,
            selected: selected,
            onChanged: onChanged,
          ),
        ],
        child: const SizedBox(width: 260, child: Text('Sales channel')),
      );
}

final class _SalesChannelFilterChip extends StatelessWidget {
  const _SalesChannelFilterChip({
    required this.salesChannels,
    required this.selected,
    required this.onChanged,
  });

  final ValueChanged<List<String>> onChanged;
  final List<AdminSalesChannel> salesChannels;
  final List<String> selected;

  @override
  Widget build(BuildContext context) => MenuAnchor(
        style: _regionMenuStyle(context),
        menuChildren: [
          _SalesChannelChoices(
            salesChannels: salesChannels,
            selected: selected,
            onChanged: onChanged,
          ),
        ],
        builder: (context, controller, child) => DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            InkWell(
              onTap: controller.isOpen ? controller.close : controller.open,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 6, 7),
                child: Text(
                  'Sales channel: '
                  '${_salesChannelLabel(salesChannels, selected)}',
                ),
              ),
            ),
            IconButton(
              tooltip: 'Remove Sales channel filter',
              onPressed: () => onChanged(const []),
              constraints: const BoxConstraints.tightFor(width: 28, height: 32),
              icon: const Icon(Icons.close_rounded, size: 14),
            ),
          ]),
        ),
      );
}

final class _SalesChannelChoices extends StatefulWidget {
  const _SalesChannelChoices({
    required this.salesChannels,
    required this.selected,
    required this.onChanged,
  });

  final ValueChanged<List<String>> onChanged;
  final List<AdminSalesChannel> salesChannels;
  final List<String> selected;

  @override
  State<_SalesChannelChoices> createState() => _SalesChannelChoicesState();
}

final class _SalesChannelChoicesState extends State<_SalesChannelChoices> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.text.trim().toLowerCase();
    final channels = widget.salesChannels
        .where((channel) => channel.name.toLowerCase().contains(query))
        .toList(growable: false);
    return SizedBox(
      width: 292,
      height: 52 + channels.length.clamp(1, 5) * 44,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _query,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search sales channels',
              prefixIcon: Icon(Icons.search_rounded, size: 17),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final channel in channels)
                CheckboxListTile(
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: widget.selected.contains(channel.id),
                  onChanged: (_) => widget.onChanged(
                    _toggleSalesChannel(widget.selected, channel.id),
                  ),
                  title: Text(channel.name),
                ),
              if (channels.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No sales channels found'),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

List<String> _toggleSalesChannel(List<String> selected, String id) =>
    selected.contains(id)
        ? [
            for (final value in selected)
              if (value != id) value
          ]
        : [...selected, id];

String _salesChannelLabel(
  List<AdminSalesChannel> channels,
  List<String> selected,
) {
  final labels = [
    for (final channel in channels)
      if (selected.contains(channel.id)) channel.name,
  ];
  if (labels.isEmpty) return '${selected.length} selected';
  return labels.length == 1
      ? labels.single
      : '${labels.first} +${labels.length - 1}';
}
