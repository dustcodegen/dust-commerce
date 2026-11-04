import 'package:admin_app/src/customer/admin_customer_page_header.dart';
import 'package:admin_app/src/customer/admin_customer_pagination.dart';
import 'package:admin_app/src/customer/admin_customer_table_body.dart';
import 'package:admin_app/src/customer/admin_customer_toolbar.dart';
import 'package:admin_app/src/customer/admin_customer_view_model.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped customer list backed by the protected Admin API.
final class AdminCustomerPage extends StatelessWidget {
  /// Creates the customer list route.
  const AdminCustomerPage({
    required this.searchFocus,
    required this.onOpen,
    required this.onCreate,
    super.key,
  });

  /// Opens one complete customer detail route.
  final ValueChanged<String> onOpen;

  /// Opens Medusa's focused customer-create route.
  final VoidCallback onCreate;

  /// Focus target shared with the sidebar search action.
  final FocusNode searchFocus;

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerViewModel().value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            shadowColor: const Color(0x16000000),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AdminCustomerPageHeader(onCreate: onCreate),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              AdminCustomerToolbar(state: state, searchFocus: searchFocus),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              AdminCustomerTableBody(
                state: state,
                onRetry: context.readAdminCustomerViewModel().load,
                onOpen: onOpen,
              ),
              AdminCustomerPagination(state: state),
            ]),
          ),
        ),
      ),
    );
  }
}
