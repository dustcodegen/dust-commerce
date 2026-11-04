import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Compact profile table with only Medusa's visible columns.
final class AdminShippingProfileTable extends StatelessWidget {
  /// Creates profile rows and their actions.
  const AdminShippingProfileTable({
    required this.shippingProfiles,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  /// Confirms and retires one profile.
  final ValueChanged<AdminShippingProfile> onDelete;

  /// Opens one profile detail route.
  final ValueChanged<String> onOpen;

  /// Explicit rows from the Admin contract.
  final List<AdminShippingProfile> shippingProfiles;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _AdminShippingProfileTableHeader(),
          for (final profile in shippingProfiles)
            _AdminShippingProfileTableRow(
              profile: profile,
              onOpen: onOpen,
              onDelete: onDelete,
            ),
        ],
      );
}

final class _AdminShippingProfileTableHeader extends StatelessWidget {
  const _AdminShippingProfileTableHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(children: [
          Expanded(flex: 5, child: Text('Name')),
          Expanded(flex: 4, child: Text('Type')),
          SizedBox(width: 32),
        ]),
      );
}

final class _AdminShippingProfileTableRow extends StatelessWidget {
  const _AdminShippingProfileTableRow({
    required this.profile,
    required this.onOpen,
    required this.onDelete,
  });

  final ValueChanged<AdminShippingProfile> onDelete;
  final ValueChanged<String> onOpen;
  final AdminShippingProfile profile;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onOpen(profile.id),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(children: [
              Expanded(flex: 5, child: Text(profile.name)),
              Expanded(
                flex: 4,
                child: Text(
                  profile.type,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: PopupMenuButton<String>(
                  tooltip: 'Shipping profile actions',
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_horiz_rounded, size: 17),
                  onSelected: (_) => onDelete(profile),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      );
}
