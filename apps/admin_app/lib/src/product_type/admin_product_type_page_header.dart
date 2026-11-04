import 'package:flutter/material.dart';

/// Heading and actions matching Medusa's product-type list route.
final class AdminProductTypePageHeader extends StatelessWidget {
  /// Creates product-type list controls.
  const AdminProductTypePageHeader({
    required this.controller,
    required this.focusNode,
    required this.onCreate,
    required this.onSearch,
    super.key,
  });

  /// Current value search input.
  final TextEditingController controller;

  /// Focus target shared with the sidebar search action.
  final FocusNode focusNode;

  /// Opens Medusa's creation focus surface.
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
                  Text(
                    'Product Types',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Create and manage reusable product classifications.',
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
