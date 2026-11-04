import 'package:admin_app/src/product/admin_product_state.dart';
import 'package:admin_app/src/product/admin_product_table.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Product-list states and table content owned by one rebuild boundary.
final class AdminProductPageBody extends StatelessWidget {
  /// Creates the loading, failure, empty, or populated product body.
  const AdminProductPageBody({
    required this.onDelete,
    required this.onOpen,
    required this.onRetry,
    required this.state,
    super.key,
  });

  /// Deletes one selected product after host confirmation.
  final ValueChanged<AdminProduct> onDelete;

  /// Opens one product detail.
  final ValueChanged<String> onOpen;

  /// Retries the current query after an initial failure.
  final VoidCallback onRetry;

  /// Current immutable product-list state.
  final AdminProductState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminProductStatus.loading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (state.failure case Some(value: final message)
        when state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state.products.isEmpty) {
      return const Center(child: Text('No products found'));
    }
    return Stack(
      children: [
        AdminProductTable(
          products: state.products,
          onDelete: onDelete,
          onOpen: onOpen,
        ),
        if (state.status == AdminProductStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}
