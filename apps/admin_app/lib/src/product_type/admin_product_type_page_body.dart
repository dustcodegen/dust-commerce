import 'package:admin_app/src/product_type/admin_product_type_state.dart';
import 'package:admin_app/src/product_type/admin_product_type_table.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Renders loading, failure, empty and populated product-type states.
final class AdminProductTypePageBody extends StatelessWidget {
  /// Creates the product-type list body.
  const AdminProductTypePageBody({
    required this.state,
    required this.onRetry,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Current product-type state.
  final AdminProductTypeState state;

  /// Reloads the current page.
  final VoidCallback onRetry;

  /// Opens one product-type detail route.
  final ValueChanged<String> onOpen;

  /// Opens the product-type editor.
  final ValueChanged<AdminProductType> onEdit;

  /// Deletes one product type after confirmation.
  final ValueChanged<AdminProductType> onDelete;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminProductTypeStatus.loading &&
        state.productTypes.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.failure case Some(value: final message)) {
      return SizedBox(
        height: 120,
        child: Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: Text('$message Retry'),
          ),
        ),
      );
    }
    if (state.productTypes.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No records')),
      );
    }
    return Stack(
      children: [
        AdminProductTypeTable(
          productTypes: state.productTypes,
          onOpen: onOpen,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        if (state.status == AdminProductTypeStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}
