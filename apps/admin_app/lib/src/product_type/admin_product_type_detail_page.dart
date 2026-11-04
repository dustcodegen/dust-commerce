import 'dart:async';

import 'package:admin_app/src/product_type/admin_product_type_delete.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_state.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_view_model.dart';
import 'package:admin_app/src/product_type/admin_product_type_edit_drawer.dart';
import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:admin_app/src/product_type/detail/admin_product_type_data_sections.dart';
import 'package:admin_app/src/product_type/detail/admin_product_type_general_section.dart';
import 'package:admin_app/src/product_type/detail/admin_product_type_products_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped product-type detail and linked-product route.
final class AdminProductTypeDetailPage extends StatefulWidget {
  /// Creates a detail route for [productTypeId].
  const AdminProductTypeDetailPage({
    required this.productTypeId,
    required this.onBack,
    required this.onOpenProduct,
    super.key,
  });

  /// Returns to Product Types.
  final VoidCallback onBack;

  /// Opens one linked product.
  final ValueChanged<String> onOpenProduct;

  /// Stable product-type identifier.
  final String productTypeId;

  @override
  State<AdminProductTypeDetailPage> createState() =>
      _AdminProductTypeDetailPageState();
}

final class _AdminProductTypeDetailPageState
    extends State<AdminProductTypeDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .readAdminProductTypeDetailViewModel()
            .load(widget.productTypeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductTypeDetailViewModel().value;
    return switch (state.productType) {
      Some(value: final productType) => _body(context, state, productType),
      None() when state.status == AdminProductTypeDetailStatus.loading =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      None() => _failure(context, state),
    };
  }

  Widget _body(
    BuildContext context,
    AdminProductTypeDetailState state,
    AdminProductType productType,
  ) =>
      ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
              child: Column(children: [
                AdminProductTypeGeneralSection(
                  productType: productType,
                  onEdit: () => _edit(context, productType),
                  onDelete: () => _delete(context, productType),
                ),
                const SizedBox(height: 12),
                AdminProductTypeProductsSection(
                  state: state,
                  onOpen: widget.onOpenProduct,
                ),
                const SizedBox(height: 12),
                AdminProductTypeDataSections(productType: productType),
              ]),
            ),
          ),
        ],
      );

  Widget _failure(BuildContext context, AdminProductTypeDetailState state) =>
      Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(switch (state.failure) {
            Some(value: final message) => message,
            None() => 'Unable to load this product type.',
          }),
          const SizedBox(height: 12),
          Row(mainAxisSize: MainAxisSize.min, children: [
            OutlinedButton(
                onPressed: widget.onBack, child: const Text('Types')),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => context
                  .readAdminProductTypeDetailViewModel()
                  .load(widget.productTypeId),
              child: const Text('Retry'),
            ),
          ]),
        ]),
      );

  Future<void> _edit(
    BuildContext context,
    AdminProductType productType,
  ) async {
    final updated = await showAdminProductTypeEditDrawer(context, productType);
    if (!context.mounted || updated == null) return;
    await context
        .readAdminProductTypeDetailViewModel()
        .load(widget.productTypeId);
    if (!context.mounted) return;
    unawaited(context.readAdminProductTypeViewModel().load());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product type "${updated.value}" updated.')),
    );
  }

  Future<void> _delete(
    BuildContext context,
    AdminProductType productType,
  ) async {
    if (!await confirmAdminProductTypeDelete(context, productType.value) ||
        !context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final outcome =
        await context.readAdminProductTypeViewModel().delete(productType.id);
    if (!context.mounted) return;
    if (outcome == AdminProductTypeDeleteOutcome.deleted) widget.onBack();
    messenger.showSnackBar(SnackBar(
      content: Text(adminProductTypeDeleteMessage(outcome, productType.value)),
    ));
  }
}
