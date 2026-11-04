import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Timeline built only from persisted order and payment timestamps.
final class AdminOrderActivitySection extends StatelessWidget {
  /// Creates the activity section.
  const AdminOrderActivitySection({required this.order, super.key});

  /// Complete merchant order snapshot.
  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: 'Activity',
        child: Column(children: [
          _ActivityRow(label: 'Order placed', at: order.placedAt),
          if (order.paymentCapturedAt case Some(value: final at))
            _ActivityRow(label: 'Payment captured', at: at),
          if (order.updatedAt.isAfter(order.placedAt))
            _ActivityRow(label: 'Order updated', at: order.updatedAt),
        ]),
      );
}

final class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.label, required this.at});

  final DateTime at;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 5, right: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.yMMMd().add_jm().format(at.toLocal()),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
