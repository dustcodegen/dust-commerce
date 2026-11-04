import 'package:admin_app/src/core/admin_money.dart';
import 'package:admin_app/src/order/admin_refund_payment_action.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// One source-shaped payment row with its independent refund action.
final class AdminOrderPaymentRecord extends StatelessWidget {
  /// Creates a payment row from the explicit Admin order contract.
  const AdminOrderPaymentRecord({required this.order, super.key});

  /// Merchant order containing one payment collection.
  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (order.paymentId) {
                    Some(:final value) => '#$value',
                    None() => '—',
                  },
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (order.paymentCreatedAt case Some(:final value))
                  Text(
                    DateFormat('dd MMM, yyyy, HH:mm:ss')
                        .format(value.toLocal()),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(switch (order.paymentProvider) {
                  Some(:final value) => value,
                  None() => '—',
                }),
                _AdminPaymentRecordBadge(status: order.paymentRecordStatus),
                Text(switch (order.paymentAmount) {
                  Some(:final value) => '${order.currencyCode.toUpperCase()} '
                      '${formatMinorUnits(value, order.currencyCode)}',
                  None() => '—',
                }),
                AdminRefundPaymentAction(order: order),
              ],
            ),
          ),
        ]),
      );
}

final class _AdminPaymentRecordBadge extends StatelessWidget {
  const _AdminPaymentRecordBadge({required this.status});

  final Option<AdminOrderPaymentRecordStatus> status;

  @override
  Widget build(BuildContext context) {
    final value = switch (status) {
      Some(:final value) => switch (value) {
          AdminOrderPaymentRecordStatus.pending => ('Pending', Colors.orange),
          AdminOrderPaymentRecordStatus.authorized => (
              'Authorized',
              Colors.orange
            ),
          AdminOrderPaymentRecordStatus.captured => ('Captured', Colors.green),
          AdminOrderPaymentRecordStatus.canceled => ('Canceled', Colors.red),
          AdminOrderPaymentRecordStatus.failed => ('Failed', Colors.red),
        },
      None() => ('Unknown', Colors.grey),
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: value.$2.withValues(alpha: 0.28)),
      backgroundColor: value.$2.withValues(alpha: 0.10),
      label: Text(value.$1),
    );
  }
}
