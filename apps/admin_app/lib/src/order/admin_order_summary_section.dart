import 'package:admin_app/src/core/admin_money.dart';
import 'package:admin_app/src/order/admin_order_detail_item_row.dart';
import 'package:admin_app/src/order/admin_order_return_action.dart';
import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Frozen line items and checkout totals for one order.
final class AdminOrderSummarySection extends StatelessWidget {
  /// Creates the summary section.
  const AdminOrderSummarySection({required this.order, super.key});

  /// Complete merchant order snapshot.
  final AdminOrderDetail order;

  String _money(int value) => '${order.currencyCode.toUpperCase()} '
      '${formatMinorUnits(value, order.currencyCode)}';

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: 'Summary',
        child: Column(
          children: [
            if (order.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('No line items recorded.'),
                ),
              )
            else
              for (final item in order.items) ...[
                AdminOrderDetailItemRow(item: item),
                Divider(height: 1, color: Theme.of(context).dividerColor),
              ],
            _TotalRow(label: 'Subtotal', value: _money(order.subtotal)),
            _TotalRow(
              label: switch (order.shippingName) {
                Some(value: final name) => 'Shipping ($name)',
                None() => 'Shipping',
              },
              value: _money(order.shippingTotal),
            ),
            _TotalRow(
              label: switch (order.promotionCode) {
                Some(value: final code) => 'Discount ($code)',
                None() => 'Discount',
              },
              value: '-${_money(order.discountTotal)}',
            ),
            _TotalRow(label: 'Tax', value: _money(order.tax)),
            _TotalRow(label: 'Total', value: _money(order.total), strong: true),
            AdminOrderReturnAction(order: order),
          ],
        ),
      );
}

final class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final bool strong;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: strong ? const TextStyle(fontWeight: FontWeight.w600) : null,
          ),
        ]),
      );
}
