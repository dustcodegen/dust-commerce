import 'dart:async';

import 'package:admin_app/src/product/admin_product_option_edit_drawer.dart';
import 'package:admin_app/src/product_option/admin_product_option_detail_state.dart';
import 'package:admin_app/src/product_option/admin_product_option_detail_view_model.dart';
import 'package:admin_app/src/product_option/admin_product_option_delete.dart';
import 'package:admin_app/src/product_option/admin_product_option_view_model.dart';
import 'package:admin_app/src/product_option/detail/admin_product_option_data_sections.dart';
import 'package:admin_app/src/product_option/detail/admin_product_option_general_section.dart';
import 'package:admin_app/src/product_option/detail/admin_product_option_products_section.dart';
import 'package:admin_app/src/product_option/detail/admin_product_option_values_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Complete Medusa-shaped merchant product-option detail route.
final class AdminProductOptionDetailPage extends StatefulWidget {
  /// Creates an option detail route for [productOptionId].
  const AdminProductOptionDetailPage({
    required this.productOptionId,
    required this.onBack,
    required this.onOpenProduct,
    super.key,
  });

  /// Returns to the global options table.
  final VoidCallback onBack;

  /// Opens one linked product route.
  final ValueChanged<String> onOpenProduct;

  /// Stable option identifier loaded from the admin API.
  final String productOptionId;

  @override
  State<AdminProductOptionDetailPage> createState() =>
      _AdminProductOptionDetailPageState();
}

final class _AdminProductOptionDetailPageState
    extends State<AdminProductOptionDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .readAdminProductOptionDetailViewModel()
            .load(widget.productOptionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductOptionDetailViewModel().value;
    return switch (state.productOption) {
      Some(value: final option) => _DetailBody(
          productOption: option,
          onBack: widget.onBack,
          onOpenProduct: widget.onOpenProduct,
        ),
      None() when state.status == AdminProductOptionDetailStatus.loading =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      None() => _Failure(
          state: state,
          onBack: widget.onBack,
          onRetry: () => context
              .readAdminProductOptionDetailViewModel()
              .load(widget.productOptionId),
        ),
    };
  }
}

final class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.productOption,
    required this.onBack,
    required this.onOpenProduct,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onOpenProduct;
  final AdminProductOptionDetail productOption;

  @override
  Widget build(BuildContext context) {
    Future<void> edit() async {
      final title =
          await showAdminProductOptionEditDrawer(context, productOption);
      if (title == null || !context.mounted) return;
      unawaited(context.readAdminProductOptionViewModel().load());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product option "$title" updated.')),
      );
    }

    Future<void> delete() async {
      if (!await confirmAdminProductOptionDelete(
            context,
            productOption.title,
          ) ||
          !context.mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      final outcome = await context
          .readAdminProductOptionViewModel()
          .delete(productOption.id);
      if (!context.mounted) return;
      if (outcome == AdminProductOptionDeleteOutcome.deleted) onBack();
      messenger.showSnackBar(SnackBar(
        content: Text(adminProductOptionDeleteMessage(
          outcome,
          productOption.title,
        )),
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminProductOptionGeneralSection(
                  productOption: productOption,
                  onEdit: edit,
                  onDelete: delete,
                ),
                const SizedBox(height: 12),
                AdminProductOptionValuesSection(
                  values: productOption.values,
                  onEdit: edit,
                ),
                const SizedBox(height: 12),
                AdminProductOptionProductsSection(
                  products: productOption.products,
                  onOpen: onOpenProduct,
                ),
                const SizedBox(height: 12),
                AdminProductOptionDataSections(productOption: productOption),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _Failure extends StatelessWidget {
  const _Failure(
      {required this.state, required this.onBack, required this.onRetry});

  final VoidCallback onBack;
  final VoidCallback onRetry;
  final AdminProductOptionDetailState state;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(switch (state.failure) {
            Some(value: final message) => message,
            None() => 'Unable to load this product option.',
          }),
          const SizedBox(height: 12),
          Row(mainAxisSize: MainAxisSize.min, children: [
            OutlinedButton(onPressed: onBack, child: const Text('Options')),
            const SizedBox(width: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ]),
        ]),
      );
}
