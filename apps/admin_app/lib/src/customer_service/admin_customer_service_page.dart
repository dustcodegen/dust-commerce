import 'package:admin_app/src/customer_service/admin_customer_service_body.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_detail_dialog.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_pagination.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_toolbar.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped support inbox backed by the protected Admin API.
final class AdminCustomerServicePage extends StatefulWidget {
  /// Creates the support inbox route.
  const AdminCustomerServicePage({required this.searchFocus, super.key});

  /// Focus target shared with the sidebar search action.
  final FocusNode searchFocus;

  @override
  State<AdminCustomerServicePage> createState() =>
      _AdminCustomerServicePageState();
}

final class _AdminCustomerServicePageState
    extends State<AdminCustomerServicePage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerServiceViewModel().value;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Customer Service',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      Text(
                        '${state.count} '
                        '${state.count == 1 ? 'request' : 'requests'}',
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                AdminCustomerServiceToolbar(
                  controller: _query,
                  focusNode: widget.searchFocus,
                  state: state,
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                AdminCustomerServiceBody(
                  state: state,
                  onRetry: context.readAdminCustomerServiceViewModel().load,
                  onOpen: _open,
                ),
                AdminCustomerServicePagination(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(AdminCustomerServiceRequest request) => showDialog<void>(
        context: context,
        builder: (context) =>
            AdminCustomerServiceDetailDialog(request: request),
      );
}
