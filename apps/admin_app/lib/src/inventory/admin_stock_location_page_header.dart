import 'package:flutter/material.dart';

/// Heading and search control for the location list.
final class AdminStockLocationPageHeader extends StatelessWidget {
  /// Creates location-list controls.
  const AdminStockLocationPageHeader({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    super.key,
  });

  /// Search controller.
  final TextEditingController controller;

  /// Search focus target.
  final FocusNode focusNode;

  /// Applies the current search value.
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Locations',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 3),
                  Text(
                    'Manage the warehouses used to fulfill orders.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 196,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: (_) => onSearch(),
                decoration: const InputDecoration(
                  hintText: 'Search locations',
                  prefixIcon: Icon(Icons.search_rounded, size: 17),
                ),
              ),
            ),
          ],
        ),
      );
}
