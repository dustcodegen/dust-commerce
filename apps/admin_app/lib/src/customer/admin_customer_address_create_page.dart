import 'package:admin_app/src/customer/admin_customer_address_create_form.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's full-screen customer-address focus surface.
Future<AdminCustomerDetail?> showAdminCustomerAddressCreatePage(
  BuildContext context,
  String customerId,
) =>
    showGeneralDialog<AdminCustomerDetail>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Create customer address',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) =>
          AdminCustomerAddressCreateForm(customerId: customerId),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
