import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// General profile identity and destructive action.
final class AdminShippingProfileGeneralSection extends StatelessWidget {
  /// Creates Medusa's General section.
  const AdminShippingProfileGeneralSection({
    required this.shippingProfile,
    required this.onDelete,
    super.key,
  });

  /// Opens typed deletion confirmation.
  final VoidCallback onDelete;

  /// Explicit profile identity.
  final AdminShippingProfile shippingProfile;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor: const Color(0x16000000),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(children: [
              Expanded(
                child: Text(
                  shippingProfile.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Shipping profile actions',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz_rounded, size: 17),
                onSelected: (_) => onDelete(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ]),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(children: [
              Expanded(
                child: Text(
                  'Type',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(shippingProfile.type),
            ]),
          ),
        ]),
      );
}
