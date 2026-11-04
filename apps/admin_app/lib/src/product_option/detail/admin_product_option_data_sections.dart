import 'dart:convert';

import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa's metadata and JSON cards using only allowlisted response fields.
final class AdminProductOptionDataSections extends StatelessWidget {
  /// Creates the safe diagnostic cards.
  const AdminProductOptionDataSections({
    required this.productOption,
    super.key,
  });

  /// Explicit admin response displayed without persistence internals.
  final AdminProductOptionDetail productOption;

  @override
  Widget build(BuildContext context) => Column(
        children: [
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
        ],
      );

  Map<String, Object> get _safeJson => {
        'id': productOption.id,
        'title': productOption.title,
        'is_exclusive': productOption.isExclusive,
        'values': [
          for (final item in productOption.values)
            {'id': item.id, 'value': item.value, 'rank': item.rank},
        ],
        'products': [
          for (final item in productOption.products)
            {'id': item.id, 'title': item.title},
        ],
      };
}
