import 'package:flutter/material.dart';

/// Heading and primary action matching Medusa's profile list route.
final class AdminShippingProfilePageHeader extends StatelessWidget {
  /// Creates the profile-list header.
  const AdminShippingProfilePageHeader({
    required this.onCreate,
    super.key,
  });

  /// Opens the full-screen creation surface.
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
                  'Shipping Profiles',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'Group products with similar shipping requirements into '
                  'profiles.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          OutlinedButton(onPressed: onCreate, child: const Text('Create')),
        ]),
      );
}
