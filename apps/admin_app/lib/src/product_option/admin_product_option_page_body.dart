import 'package:admin_app/src/product_option/admin_product_option_state.dart';
import 'package:admin_app/src/product_option/admin_product_option_table.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Renders loading, failure, empty and populated option-list states.
final class AdminProductOptionPageBody extends StatelessWidget {
  /// Creates the option-list body.
  const AdminProductOptionPageBody({
    required this.state,
    required this.onRetry,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  /// Current option-list state.
  final AdminProductOptionState state;

  /// Reloads the current page.
  final VoidCallback onRetry;

  /// Opens one option detail route.
  final ValueChanged<String> onOpen;

  /// Deletes one option after confirmation.
  final ValueChanged<AdminProductOptionSummary> onDelete;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminProductOptionStatus.loading &&
        state.productOptions.isEmpty) {
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
    if (state.productOptions.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No records')),
      );
    }
    return Stack(
      children: [
        AdminProductOptionTable(
          productOptions: state.productOptions,
          onOpen: onOpen,
          onDelete: onDelete,
        ),
        if (state.status == AdminProductOptionStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}
