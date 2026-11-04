import 'package:admin_app/src/product_option/admin_product_option_create_form.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's full-screen product-option creation focus surface.
Future<AdminProductOptionDetail?> showAdminProductOptionCreatePage(
  BuildContext context,
) =>
    showGeneralDialog<AdminProductOptionDetail>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Create product option',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) => const AdminProductOptionCreateForm(),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
