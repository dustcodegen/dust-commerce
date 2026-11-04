import 'dart:async';

import 'package:admin_app/src/product/admin_product_shipping_profile_drawer.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens the editor, refreshes the product table, and confirms a saved change.
Future<void> editAdminProductShippingProfile(
  BuildContext context,
  AdminProductDetail product,
) async {
  final saved = await showAdminProductShippingProfileDrawer(context, product);
  if (saved != true || !context.mounted) return;
  unawaited(context.readAdminProductViewModel().load());
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Product shipping profile updated.')),
  );
}
