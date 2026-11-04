import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Non-mutating server summary shown before import confirmation exists.
final class AdminProductImportSummaryCard extends StatelessWidget {
  /// Creates the Medusa-shaped summary card.
  const AdminProductImportSummaryCard({required this.preview, super.key});

  /// Staged transaction and exact unique-product counts.
  final AdminProductImportPreview preview;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 14),
            _CountRow(
              label: 'Products to create',
              value: preview.summary.toCreate,
            ),
            const SizedBox(height: 10),
            _CountRow(
              label: 'Products to update',
              value: preview.summary.toUpdate,
            ),
          ],
        ),
      );
}

final class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(label)),
        Container(
          constraints: const BoxConstraints(minWidth: 34),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('$value', textAlign: TextAlign.center),
        ),
      ]);
}
