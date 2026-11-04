import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa's Metadata and JSON cards using the explicit group allowlist.
final class AdminCustomerGroupDataSections extends StatelessWidget {
  /// Creates safe diagnostic cards.
  const AdminCustomerGroupDataSections({
    required this.customerGroup,
    super.key,
  });

  /// Explicit Admin response displayed without persistence internals.
  final AdminCustomerGroupDetail customerGroup;

  @override
  Widget build(BuildContext context) => Column(children: [
        _AdminCustomerGroupDataCard(
          title: 'Metadata',
          child: _AdminCustomerGroupMetadata(metadata: customerGroup.metadata),
        ),
        const SizedBox(height: 12),
        _AdminCustomerGroupDataCard(
          title: 'JSON',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(_safeJson),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
            ),
          ),
        ),
      ]);

  Map<String, Object?> get _safeJson => {
        'id': customerGroup.id,
        'name': customerGroup.name,
        'customers': [
          for (final customer in customerGroup.customers) {'id': customer.id},
        ],
        'metadata': customerGroup.metadataValue,
        'created_at': customerGroup.createdAt.toIso8601String(),
        'updated_at': customerGroup.updatedAt.toIso8601String(),
      };
}

final class _AdminCustomerGroupMetadata extends StatelessWidget {
  const _AdminCustomerGroupMetadata({required this.metadata});

  final Option<Map<String, Object?>> metadata;

  @override
  Widget build(BuildContext context) {
    final values = switch (metadata) {
      Some(:final value) => value.entries.toList(growable: false),
      None() => const <MapEntry<String, Object?>>[],
    };
    if (values.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '0 key-value pairs',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return Column(children: [
      for (final entry in values)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(child: SelectableText(jsonEncode(entry.value))),
          ]),
        ),
    ]);
  }
}

final class _AdminCustomerGroupDataCard extends StatelessWidget {
  const _AdminCustomerGroupDataCard({
    required this.title,
    required this.child,
  });

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor: const Color(0x12000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          child,
        ]),
      );
}
