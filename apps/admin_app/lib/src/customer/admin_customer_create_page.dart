import 'package:admin_app/src/customer/admin_customer_create_form.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's full-screen customer creation focus surface.
Future<AdminCustomerDetail?> showAdminCustomerCreatePage(
  BuildContext context,
) =>
    showGeneralDialog<AdminCustomerDetail>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Create customer',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) => const AdminCustomerCreateForm(),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
