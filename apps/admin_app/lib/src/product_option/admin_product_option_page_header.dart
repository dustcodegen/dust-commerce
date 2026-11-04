import 'package:flutter/material.dart';

/// Header controls for the global product-option list.
final class AdminProductOptionPageHeader extends StatelessWidget {
  /// Creates the heading, search field, and create action.
  const AdminProductOptionPageHeader({
    required this.controller,
    required this.focusNode,
    required this.onCreate,
    required this.onSearch,
    super.key,
  });

  /// Current title search input.
  final TextEditingController controller;

  /// Focus target shared with the sidebar search action.
  final FocusNode focusNode;

  /// Opens the creation drawer.
  final VoidCallback onCreate;

  /// Applies the current search input.
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
                  Text('Options',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 3),
                  Text(
                    'Manage product options and their associated values.',
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
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search_rounded, size: 17),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onCreate, child: const Text('Create')),
          ],
        ),
      );
}

/// Fixed global-option filter matching Medusa's default list state.
final class AdminProductOptionToolbar extends StatelessWidget {
  /// Creates the global filter toolbar.
  const AdminProductOptionToolbar({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(children: [
          Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Text('Type is Global')),
        ]),
      );
}
