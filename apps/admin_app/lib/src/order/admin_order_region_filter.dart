part of 'admin_order_toolbar.dart';

final class _RegionFilterSubmenu extends StatelessWidget {
  const _RegionFilterSubmenu({
    required this.regions,
    required this.selected,
    required this.onChanged,
  });

  final ValueChanged<List<String>> onChanged;
  final List<AdminRegion> regions;
  final List<String> selected;

  @override
  Widget build(BuildContext context) => SubmenuButton(
        menuStyle: _regionMenuStyle(context),
        submenuIcon: const WidgetStatePropertyAll(SizedBox.shrink()),
        menuChildren: [
          _RegionChoices(
            regions: regions,
            selected: selected,
            onChanged: onChanged,
          ),
        ],
        child: const SizedBox(
          width: 260,
          child: Text('Region'),
        ),
      );
}

final class _RegionFilterChip extends StatelessWidget {
  const _RegionFilterChip({
    required this.regions,
    required this.selected,
    required this.onChanged,
  });

  final ValueChanged<List<String>> onChanged;
  final List<AdminRegion> regions;
  final List<String> selected;

  @override
  Widget build(BuildContext context) => MenuAnchor(
        style: _regionMenuStyle(context),
        menuChildren: [
          _RegionChoices(
            regions: regions,
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
                child: Text('Region: ${_regionLabel(regions, selected)}'),
              ),
            ),
            IconButton(
              tooltip: 'Remove Region filter',
              onPressed: () => onChanged(const []),
              constraints: const BoxConstraints.tightFor(width: 28, height: 32),
              icon: const Icon(Icons.close_rounded, size: 14),
            ),
          ]),
        ),
      );
}

final class _RegionChoices extends StatefulWidget {
  const _RegionChoices({
    required this.regions,
    required this.selected,
    required this.onChanged,
  });

  final ValueChanged<List<String>> onChanged;
  final List<AdminRegion> regions;
  final List<String> selected;

  @override
  State<_RegionChoices> createState() => _RegionChoicesState();
}

final class _RegionChoicesState extends State<_RegionChoices> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.text.trim().toLowerCase();
    final regions = widget.regions
        .where((region) => region.name.toLowerCase().contains(query))
        .toList(growable: false);
    return SizedBox(
      width: 292,
      height: 52 + regions.length.clamp(1, 5) * 44,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _query,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search regions',
              prefixIcon: Icon(Icons.search_rounded, size: 17),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final region in regions)
                CheckboxListTile(
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: widget.selected.contains(region.id),
                  onChanged: (_) => widget.onChanged(
                    _toggleRegion(widget.selected, region.id),
                  ),
                  title: Text(region.name),
                ),
              if (regions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No regions found'),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

List<String> _toggleRegion(List<String> selected, String id) =>
    selected.contains(id)
        ? [
            for (final value in selected)
              if (value != id) value
          ]
        : [...selected, id];

String _regionLabel(List<AdminRegion> regions, List<String> selected) {
  final labels = [
    for (final region in regions)
      if (selected.contains(region.id)) region.name,
  ];
  if (labels.isEmpty) return '${selected.length} selected';
  return labels.length == 1
      ? labels.single
      : '${labels.first} +${labels.length - 1}';
}

MenuStyle _regionMenuStyle(BuildContext context) => MenuStyle(
      backgroundColor:
          WidgetStatePropertyAll(Theme.of(context).colorScheme.surface),
      padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
    );
