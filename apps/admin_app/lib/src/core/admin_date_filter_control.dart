import 'package:admin_app/src/core/admin_date_filter_preset.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Active Medusa date-filter chip with preset, custom, and clear actions.
final class AdminDateFilterChip extends StatelessWidget {
  /// Creates one editable active filter.
  const AdminDateFilterChip({
    required this.label,
    required this.value,
    required this.onChanged,
    this.now = DateTime.now,
    super.key,
  });

  /// Column label such as Created or Updated.
  final String label;

  /// Supplies local calendar time when the menu opens.
  final DateTime Function() now;

  /// Applies a preset, custom range, or empty filter.
  final ValueChanged<AdminDateFilter> onChanged;

  /// Current server query value.
  final AdminDateFilter value;

  @override
  Widget build(BuildContext context) {
    final current = now();
    return MenuAnchor(
      menuChildren: [
        _AdminDateFilterChoices(
          navigator: Navigator.of(context, rootNavigator: true),
          value: value,
          now: current,
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
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(6)),
            onTap: controller.isOpen ? controller.close : controller.open,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 6, 7),
              child: Text('$label: ${adminDateFilterLabel(value, current)}'),
            ),
          ),
          IconButton(
            tooltip: 'Remove $label filter',
            onPressed: () => onChanged(const AdminDateFilter()),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.only(right: 4),
            constraints: const BoxConstraints.tightFor(width: 28, height: 32),
            icon: const Icon(Icons.close_rounded, size: 14),
          ),
        ]),
      ),
    );
  }
}

/// Inactive date filter nested beneath Medusa's Add filter menu.
final class AdminDateFilterSubmenu extends StatelessWidget {
  /// Creates one source-shaped preset submenu.
  const AdminDateFilterSubmenu({
    required this.label,
    required this.onChanged,
    this.value = const AdminDateFilter(),
    this.now = DateTime.now,
    this.style,
    this.menuStyle,
    super.key,
  });

  /// Column label such as Created or Updated.
  final String label;

  /// Optional flyout style inherited from its table toolbar.
  final MenuStyle? menuStyle;

  /// Supplies local calendar time when rendered.
  final DateTime Function() now;

  /// Applies the selected query comparison.
  final ValueChanged<AdminDateFilter> onChanged;

  /// Current bounds used as the custom picker initial value.
  final AdminDateFilter value;

  /// Optional Add-filter row style.
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final current = now();
    return SubmenuButton(
      style: style,
      menuStyle: menuStyle,
      submenuIcon: const WidgetStatePropertyAll(SizedBox.shrink()),
      menuChildren: [
        _AdminDateFilterChoices(
          navigator: Navigator.of(context, rootNavigator: true),
          value: value,
          now: current,
          onChanged: onChanged,
        ),
      ],
      child: Text(label),
    );
  }
}

final class _AdminDateFilterChoices extends StatelessWidget {
  const _AdminDateFilterChoices({
    required this.navigator,
    required this.value,
    required this.now,
    required this.onChanged,
  });

  final NavigatorState navigator;
  final DateTime now;
  final ValueChanged<AdminDateFilter> onChanged;
  final AdminDateFilter value;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final preset in AdminDateFilterPreset.values)
            MenuItemButton(
              onPressed: () =>
                  onChanged(adminDateFilterFromPreset(preset, now)),
              child: Text(preset.label),
            ),
          MenuItemButton(
            onPressed: () async {
              final range = await showDateRangePicker(
                context: navigator.context,
                firstDate: DateTime(2000),
                lastDate: DateTime(now.year + 1, 12, 31),
                initialDateRange: adminDateFilterInitialRange(value, now),
              );
              if (range == null || !navigator.mounted) return;
              onChanged(AdminDateFilter(
                greaterThanOrEqual: Some(range.start),
                lessThanOrEqual: Some(adminDateFilterEndOfDay(range.end)),
              ));
            },
            child: const Text('Custom'),
          ),
        ],
      );
}
