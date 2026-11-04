import 'package:flutter/material.dart';

/// Product-table title and feature actions.
final class AdminProductPageHeader extends StatelessWidget {
  /// Creates the product action row.
  const AdminProductPageHeader({
    required this.onExport,
    required this.onImport,
    required this.onCreate,
    super.key,
  });

  /// Opens product creation.
  final VoidCallback onCreate;

  /// Opens filtered product export.
  final VoidCallback onExport;

  /// Opens product import when that slice is available.
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Text('Products', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            OutlinedButton(onPressed: onExport, child: const Text('Export')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onImport, child: const Text('Import')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onCreate, child: const Text('Create')),
          ],
        ),
      );
}
