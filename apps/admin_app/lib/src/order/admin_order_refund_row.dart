import 'package:admin_app/src/core/admin_money.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// One source-shaped refund audit beneath its captured payment.
final class AdminOrderRefundRow extends StatelessWidget {
  /// Creates a refund row without provider-private metadata.
  const AdminOrderRefundRow({
    required this.refund,
    required this.currencyCode,
    super.key,
  });

  /// Payment currency shared by the refund amount.
  final String currencyCode;

  /// Immutable refund audit.
  final AdminRefund refund;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(
            Icons.south_east_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    const Text(
                      'Refund',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (refund.note case Some(:final value))
                      Tooltip(
                        message: value,
                        child: const Icon(Icons.description_outlined, size: 15),
                      ),
                    if (refund.refundReason case Some(:final value))
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(value.label),
                      ),
                  ],
                ),
                Text(
                  DateFormat('dd MMM, yyyy, HH:mm:ss')
                      .format(refund.createdAt.toLocal()),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '- ${currencyCode.toUpperCase()} '
            '${formatMinorUnits(refund.amount, currencyCode)}',
          ),
          const SizedBox(width: 40),
        ]),
      );
}
