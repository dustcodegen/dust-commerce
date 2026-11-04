import 'package:admin_app/src/order/admin_order_activity_section.dart';
import 'package:admin_app/src/order/admin_order_customer_section.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:admin_app/src/order/admin_return_view_model.dart';
import 'package:admin_app/src/order/admin_order_fulfillment_section.dart';
import 'package:admin_app/src/order/admin_order_general_section.dart';
import 'package:admin_app/src/order/admin_order_payment_section.dart';
import 'package:admin_app/src/order/admin_order_summary_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_order_detail_body.dart';

/// Protected Medusa-shaped route for one merchant order snapshot.
final class AdminOrderDetailPage extends StatefulWidget {
  /// Creates the detail route for [orderId].
  const AdminOrderDetailPage({
    required this.orderId,
    required this.onBack,
    super.key,
  });

  /// Returns to the order table.
  final VoidCallback onBack;

  /// Stable order identifier loaded from the Admin API.
  final String orderId;

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

final class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AdminOrderDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) _load();
  }

  void _load() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.readAdminOrderDetailViewModel().load(widget.orderId);
          context.readAdminReturnViewModel().loadRequested(widget.orderId);
        }
      });

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminOrderDetailViewModel().value;
    return switch (state.order) {
      Some(value: final order) => _OrderDetailBody(
          order: order,
          onBack: widget.onBack,
        ),
      None() when state.status == AdminOrderDetailStatus.loading =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      None() => _OrderDetailFailure(
          message: switch (state.failure) {
            Some(value: final message) => message,
            None() => 'Unable to load this order.',
          },
          onBack: widget.onBack,
          onRetry: _load,
        ),
    };
  }
}

final class _OrderDetailFailure extends StatelessWidget {
  const _OrderDetailFailure({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              OutlinedButton(onPressed: onBack, child: const Text('Orders')),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ]),
          ],
        ),
      );
}
