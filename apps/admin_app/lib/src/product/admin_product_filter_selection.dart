part of 'admin_product_filter_bar.dart';

final class _MultiFilterChoices extends StatelessWidget {
  const _MultiFilterChoices({
    required this.choices,
    required this.selected,
    required this.onChanged,
  });

  final List<_FilterChoice> choices;
  final ValueChanged<List<String>> onChanged;
  final List<String> selected;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final choice in choices)
            CheckboxMenuButton(
              value: selected.contains(choice.id),
              closeOnActivate: false,
              onChanged: (_) => onChanged(_toggle(selected, choice.id)),
              child: Text(choice.label),
            ),
        ],
      );
}

final class _SelectFilterSubmenu extends StatelessWidget {
  const _SelectFilterSubmenu({
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
  Widget build(BuildContext context) => SubmenuButton(
        style: _addFilterItemStyle,
        menuStyle: _filterMenuStyle(context),
        submenuIcon: const WidgetStatePropertyAll(SizedBox.shrink()),
        menuChildren: [
          _MultiFilterChoices(
            choices: choices,
            selected: selected,
            onChanged: onChanged,
          ),
        ],
        child: Text(label),
      );
}

List<String> _toggle(List<String> selected, String id) => selected.contains(id)
    ? [
        for (final value in selected)
          if (value != id) value,
      ]
    : [...selected, id];
