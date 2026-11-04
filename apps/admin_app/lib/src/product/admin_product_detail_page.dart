import 'dart:async';

import 'package:admin_app/src/product/admin_product_detail_media_actions.dart';
import 'package:admin_app/src/product/admin_product_delete.dart';
import 'package:admin_app/src/product/admin_product_detail_failure.dart';
import 'package:admin_app/src/product/admin_product_detail_state.dart';
import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:admin_app/src/product/admin_product_edit_drawer.dart';
import 'package:admin_app/src/product/admin_product_media_editor.dart';
import 'package:admin_app/src/product/admin_product_organization_drawer.dart';
import 'package:admin_app/src/product/admin_product_sales_channel_actions.dart';
import 'package:admin_app/src/product/admin_product_stock_page.dart';
import 'package:admin_app/src/product/admin_product_shipping_profile_actions.dart';
import 'package:admin_app/src/product/admin_product_variant_edit_drawer.dart';
import 'package:admin_app/src/product/admin_product_variant_pricing_page.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:admin_app/src/product/detail/admin_product_general_section.dart';
import 'package:admin_app/src/product/detail/admin_product_media_section.dart';
import 'package:admin_app/src/product/detail/admin_product_option_section.dart';
import 'package:admin_app/src/product/detail/admin_product_sidebar_sections.dart';
import 'package:admin_app/src/product/detail/admin_product_variant_section.dart';
import 'package:admin_app/src/product_type/admin_product_type_state.dart';
import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_product_detail_body.dart';

/// Complete Medusa-shaped merchant product detail route.
final class AdminProductDetailPage extends StatefulWidget {
  /// Creates a detail route for [productId].
  const AdminProductDetailPage({
    required this.productId,
    required this.onBack,
    required this.onOpenOption,
    required this.onOpenShippingProfile,
    super.key,
  });

  /// Returns to the product table.
  final VoidCallback onBack;

  /// Opens one linked option on its dedicated Medusa route.
  final ValueChanged<String> onOpenOption;

  /// Opens the current shipping profile in Settings.
  final ValueChanged<String> onOpenShippingProfile;

  /// Stable product identifier loaded from the admin API.
  final String productId;

  @override
  State<AdminProductDetailPage> createState() => _AdminProductDetailPageState();
}

final class _AdminProductDetailPageState extends State<AdminProductDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.readAdminProductDetailViewModel().load(widget.productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductDetailViewModel().value;
    return switch (state.product) {
      Some(value: final product) => _DetailBody(
          product: product,
          salesChannels: state.salesChannels,
          totalSalesChannels: state.totalSalesChannels,
          onBack: widget.onBack,
          onOpenOption: widget.onOpenOption,
          onOpenShippingProfile: widget.onOpenShippingProfile,
        ),
      None() when state.status == AdminProductDetailStatus.loading =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      None() => AdminProductDetailFailure(
          state: state,
          onBack: widget.onBack,
          onRetry: () =>
              context.readAdminProductDetailViewModel().load(widget.productId),
        ),
    };
  }
}
