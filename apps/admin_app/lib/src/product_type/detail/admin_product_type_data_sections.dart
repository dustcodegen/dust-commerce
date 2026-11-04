import 'dart:convert';

import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa's Metadata and JSON cards using the explicit type allowlist.
final class AdminProductTypeDataSections extends StatelessWidget {
  /// Creates safe diagnostic cards.
  const AdminProductTypeDataSections({required this.productType, super.key});

  /// Explicit admin response displayed without persistence internals.
  final AdminProductType productType;

  @override
  Widget build(BuildContext context) => Column(children: [
        AdminProductDetailSection(
          title: 'Metadata',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              '0 key-value pairs',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AdminProductDetailSection(
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

  Map<String, Object> get _safeJson => {
        'id': productType.id,
        'value': productType.value,
        'created_at': productType.createdAt.toIso8601String(),
        'updated_at': productType.updatedAt.toIso8601String(),
      };
}
