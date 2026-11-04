import 'package:admin_app/src/customer_group/admin_customer_group_create_form.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's full-screen customer-group creation focus surface.
Future<AdminCustomerGroup?> showAdminCustomerGroupCreatePage(
  BuildContext context,
) =>
    showGeneralDialog<AdminCustomerGroup>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Create customer group',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) => const AdminCustomerGroupCreateForm(),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
