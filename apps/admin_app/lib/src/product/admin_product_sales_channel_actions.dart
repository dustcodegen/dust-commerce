import 'dart:async';

import 'package:admin_app/src/product/admin_product_sales_channel_editor.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens the editor, refreshes the product table, and confirms a saved change.
Future<void> editAdminProductSalesChannels(
  BuildContext context,
  AdminProductDetail product,
  List<AdminSalesChannel> assigned,
) async {
  final saved = await showAdminProductSalesChannelEditor(
    context,
    product,
    assigned,
  );
  if (saved != true || !context.mounted) return;
  unawaited(context.readAdminProductViewModel().load());
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Product sales channels updated.')),
  );
}
