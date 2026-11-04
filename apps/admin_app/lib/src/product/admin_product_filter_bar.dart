import 'package:admin_app/src/core/admin_date_filter_control.dart';
import 'package:admin_app/src/product/admin_product_state.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

part 'admin_product_filter_controls.dart';
part 'admin_product_filter_selection.dart';
part 'admin_product_filter_styles.dart';

typedef _FilterChoice = ({String id, String label});

/// Source-shaped product filters backed only by implemented Admin APIs.
final class AdminProductFilterBar extends StatelessWidget {
  /// Creates the Add filter menu and active filter controls.
  const AdminProductFilterBar({required this.state, super.key});

  /// Current server query and filter-choice state.
  final AdminProductState state;

  @override
  Widget build(BuildContext context) {
    final products = context.readAdminProductViewModel();
    final statuses = [
      for (final status in AdminProductLifecycle.values)
        (id: status.name, label: _title(status.name)),
    ];
    final types = [
      for (final type in state.productTypes) (id: type.id, label: type.value),
    ];
    final tags = [
      for (final tag in state.productTags) (id: tag.id, label: tag.value),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _AddFilterMenu(
          state: state,
          statuses: statuses,
          types: types,
          tags: tags,
        ),
        if (state.statuses.isNotEmpty)
          _MultiFilterChip(
            label: 'Status',
            choices: statuses,
            selected: state.statuses.map((status) => status.name).toList(),
            onChanged: (ids) => products.filterByStatuses([
              for (final status in AdminProductLifecycle.values)
                if (ids.contains(status.name)) status,
            ]),
          ),
        if (state.typeIds.isNotEmpty)
          _MultiFilterChip(
            label: 'Type',
            choices: types,
            selected: state.typeIds,
            onChanged: products.filterByTypes,
          ),
        if (state.tagIds.isNotEmpty)
          _MultiFilterChip(
            label: 'Tag',
            choices: tags,
            selected: state.tagIds,
            onChanged: products.filterByTags,
          ),
        if (!state.createdAt.isEmpty)
          AdminDateFilterChip(
            label: 'Created',
            value: state.createdAt,
            onChanged: (value) => products.filterByCreatedAt(
              from: value.greaterThanOrEqual,
              to: value.lessThanOrEqual,
            ),
          ),
        if (!state.updatedAt.isEmpty)
          AdminDateFilterChip(
            label: 'Updated',
            value: state.updatedAt,
            onChanged: (value) => products.filterByUpdatedAt(
              from: value.greaterThanOrEqual,
              to: value.lessThanOrEqual,
            ),
          ),
        if (state.hasFilters)
          TextButton(
              onPressed: products.clearFilters, child: const Text('Clear all')),
        if (state.filterOptionsStatus == AdminFilterOptionsStatus.loading)
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        if (state.filterOptionsStatus == AdminFilterOptionsStatus.failed)
          IconButton(
            tooltip: state.filterOptionsFailure.match(
              some: (message) => '$message Retry',
              none: () => 'Retry filter choices',
            ),
            onPressed: products.loadFilterOptions,
            icon: const Icon(Icons.refresh_rounded, size: 17),
          ),
      ],
    );
  }
}

String _title(String value) => value.isEmpty
    ? value
    : '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
