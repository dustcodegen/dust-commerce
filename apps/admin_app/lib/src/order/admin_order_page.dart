import 'package:admin_app/src/order/admin_order_pagination.dart';
import 'package:admin_app/src/order/admin_order_export_drawer.dart';
import 'package:admin_app/src/order/admin_order_state.dart';
import 'package:admin_app/src/order/admin_order_table.dart';
import 'package:admin_app/src/order/admin_order_toolbar.dart';
import 'package:admin_app/src/order/admin_order_view_model.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped order route backed by the authenticated Admin API.
final class AdminOrderPage extends StatefulWidget {
  /// Creates the merchant order table.
  const AdminOrderPage({
    required this.searchFocus,
    required this.onOpen,
    super.key,
  });

  /// Opens one order on its dedicated detail screen.
  final ValueChanged<String> onOpen;

  /// Focus target shared with the sidebar search action.
  final FocusNode searchFocus;

  @override
  State<AdminOrderPage> createState() => _AdminOrderPageState();
}

final class _AdminOrderPageState extends State<AdminOrderPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminOrderViewModel().value;
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
                _AdminOrderHeader(onExport: () => _export(state)),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                AdminOrderToolbar(
                  controller: _query,
                  focusNode: widget.searchFocus,
                  state: state,
                  onSearch: () =>
                      context.readAdminOrderViewModel().search(_query.text),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _AdminOrderBody(
                  onOpen: widget.onOpen,
                  onRetry: context.readAdminOrderViewModel().load,
                  state: state,
                ),
                AdminOrderPagination(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _export(AdminOrderState state) async {
    final exported = await showAdminOrderExportDrawer(context, state);
    if (!mounted || exported != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order export downloaded.')),
    );
  }
}

final class _AdminOrderBody extends StatelessWidget {
  const _AdminOrderBody({
    required this.onOpen,
    required this.onRetry,
    required this.state,
  });

  final ValueChanged<String> onOpen;
  final VoidCallback onRetry;
  final AdminOrderState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminOrderListStatus.loading && state.orders.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.failure case Some(value: final message)
        when state.orders.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: Text('$message Retry'),
          ),
        ),
      );
    }
    if (state.orders.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('No orders found')),
      );
    }
    return Stack(
      children: [
        AdminOrderTable(orders: state.orders, onOpen: onOpen),
        if (state.status == AdminOrderListStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}

final class _AdminOrderHeader extends StatelessWidget {
  const _AdminOrderHeader({required this.onExport});

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Text('Orders', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            OutlinedButton(onPressed: onExport, child: const Text('Export')),
          ],
        ),
      );
}
