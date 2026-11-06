import 'package:flutter/material.dart';

/// Heading matching Medusa's promotions list route.
final class AdminPromotionPageHeader extends StatelessWidget {
  /// Creates the promotion-list header.
  const AdminPromotionPageHeader({required this.onCreate, super.key});

  /// Opens the focused promotion form.
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promotions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'View discount codes available to storefront carts.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Create promotion'),
          ),
        ]),
      );
}
