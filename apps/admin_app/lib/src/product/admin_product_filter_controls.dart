part of 'admin_product_filter_bar.dart';

final class _AddFilterMenu extends StatelessWidget {
  const _AddFilterMenu({
    required this.state,
    required this.statuses,
    required this.types,
    required this.tags,
  });

  final AdminProductState state;
  final List<_FilterChoice> statuses;
  final List<_FilterChoice> tags;
  final List<_FilterChoice> types;

  @override
  Widget build(BuildContext context) {
    final products = context.readAdminProductViewModel();
    final menu = <Widget>[
      if (state.typeIds.isEmpty && types.isNotEmpty)
        _SelectFilterSubmenu(
          label: 'Type',
          choices: types,
          selected: state.typeIds,
          onChanged: products.filterByTypes,
        ),
      if (state.tagIds.isEmpty && tags.isNotEmpty)
        _SelectFilterSubmenu(
          label: 'Tag',
          choices: tags,
          selected: state.tagIds,
          onChanged: products.filterByTags,
        ),
      if (state.statuses.isEmpty)
        _SelectFilterSubmenu(
          label: 'Status',
          choices: statuses,
          selected: state.statuses.map((status) => status.name).toList(),
          onChanged: (ids) => products.filterByStatuses([
            for (final status in AdminProductLifecycle.values)
              if (ids.contains(status.name)) status,
          ]),
        ),
      if (state.createdAt.isEmpty)
        AdminDateFilterSubmenu(
          label: 'Created',
          style: _addFilterItemStyle,
          menuStyle: _filterMenuStyle(context),
          onChanged: (value) => products.filterByCreatedAt(
            from: value.greaterThanOrEqual,
            to: value.lessThanOrEqual,
          ),
        ),
      if (state.updatedAt.isEmpty)
        AdminDateFilterSubmenu(
          label: 'Updated',
          style: _addFilterItemStyle,
          menuStyle: _filterMenuStyle(context),
          onChanged: (value) => products.filterByUpdatedAt(
            from: value.greaterThanOrEqual,
            to: value.lessThanOrEqual,
          ),
        ),
    ];
    if (menu.isEmpty) return const SizedBox.shrink();
    return MenuAnchor(
      style: _filterMenuStyle(context),
      alignmentOffset: const Offset(0, 8),
      menuChildren: menu,
      builder: (context, controller, child) => OutlinedButton(
        onPressed: controller.isOpen ? controller.close : controller.open,
        child: const Text('Add filter'),
      ),
    );
  }
}

final class _MultiFilterChip extends StatelessWidget {
  const _MultiFilterChip({
    required this.label,
    required this.choices,
    required this.selected,
    required this.onChanged,
  });

  final List<_FilterChoice> choices;
  final String label;
  final ValueChanged<List<String>> onChanged;
  final List<String> selected;

  @override
  Widget build(BuildContext context) => _FilterChipMenu(
        label: '$label: ${_selectionLabel(choices, selected)}',
        menuChildren: [
          _MultiFilterChoices(
            choices: choices,
            selected: selected,
            onChanged: onChanged,
          ),
        ],
        onClear: () => onChanged(const []),
      );
}

final class _FilterChipMenu extends StatelessWidget {
  const _FilterChipMenu({
    required this.label,
    required this.menuChildren,
    required this.onClear,
  });

  final String label;
  final List<Widget> menuChildren;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => MenuAnchor(
        menuChildren: menuChildren,
        builder: (context, controller, child) => DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(6)),
                onTap: controller.isOpen ? controller.close : controller.open,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 6, 7),
                  child: Text(label),
                ),
              ),
              IconButton(
                tooltip: 'Remove $label filter',
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.only(right: 4),
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 32,
                ),
                icon: const Icon(Icons.close_rounded, size: 14),
              ),
            ],
          ),
        ),
      );
}

String _selectionLabel(List<_FilterChoice> choices, List<String> selected) {
  final labels = [
    for (final choice in choices)
      if (selected.contains(choice.id)) choice.label,
  ];
  if (labels.isEmpty) return '${selected.length} selected';
  return labels.length == 1
      ? labels.single
      : '${labels.first} +${labels.length - 1}';
}
