import 'package:admin_app/src/core/admin_money.dart';
import 'package:admin_app/src/order/admin_order_payment_record.dart';
import 'package:admin_app/src/order/admin_order_refund_row.dart';
import 'package:admin_app/src/order/admin_order_status_badge.dart';
import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped payment record, refund history, and captured total.
final class AdminOrderPaymentSection extends StatelessWidget {
  /// Creates the protected payment section.
  const AdminOrderPaymentSection({required this.order, super.key});

  /// Complete merchant order snapshot.
  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: 'Payment',
        action: AdminOrderPaymentBadge(status: order.paymentStatus),
        child: Column(children: [
          switch (order.paymentId) {
            Some() => AdminOrderPaymentRecord(order: order),
            None() => const Padding(
                padding: EdgeInsets.all(24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('No payment recorded.'),
                ),
              ),
          },
          for (final refund in order.paymentRefunds)
            AdminOrderRefundRow(
              refund: refund,
              currencyCode: order.currencyCode,
            ),
          _AdminOrderPaymentTotal(order: order),
        ]),
      );
}

final class _AdminOrderPaymentTotal extends StatelessWidget {
  const _AdminOrderPaymentTotal({required this.order});

  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(children: [
          const Expanded(
            child: Text(
              'Total paid by customer',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            switch (order.paymentAmount) {
              Some(:final value) => '${order.currencyCode.toUpperCase()} '
                  '${formatMinorUnits(value, order.currencyCode)}',
              None() => '—',
            },
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ]),
      );
}
