import 'package:admin_app/src/customer_group/admin_customer_group_add_form.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's full-screen customer-group member selector.
Future<int?> showAdminCustomerGroupAddPage(
  BuildContext context, {
  required String customerGroupId,
  required Set<String> existingCustomerIds,
}) =>
    showGeneralDialog<int>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Add customers to group',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) => AdminCustomerGroupAddForm(
        customerGroupId: customerGroupId,
        existingCustomerIds: existingCustomerIds,
      ),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
