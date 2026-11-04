import 'package:commerce_app/commerce_app.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Completed transfer decision copy.
final class OrderTransferDecisionSuccess extends StatelessWidget {
  /// Creates completed decision copy.
  const OrderTransferDecisionSuccess({
    required this.action,
    required this.orderId,
    super.key,
  });

  /// Decision that completed.
  final OrderTransferAction action;

  /// Order identifier shown in the result.
  final String orderId;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            action == OrderTransferAction.accept
                ? 'Order transferred!'
                : 'Order transfer declined!',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            action == OrderTransferAction.accept
                ? 'Order $orderId has been successfully transferred to the new owner.'
                : 'Transfer of order $orderId has been successfully declined.',
            style: const TextStyle(
              color: StoreColors.foregroundSubtle,
              height: 1.5,
            ),
          ),
        ],
      );
}

/// Safe failure copy for a transfer decision.
final class OrderTransferDecisionFailure extends StatelessWidget {
  /// Creates safe failure copy.
  const OrderTransferDecisionFailure({
    required this.action,
    required this.failure,
    super.key,
  });

  /// Decision that failed.
  final OrderTransferAction action;

  /// Classified failure without server internals or capability data.
  final Option<OrderTransferFailure> failure;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            action == OrderTransferAction.accept
                ? 'There was an error accepting the transfer. Please try again.'
                : 'There was an error declining the transfer. Please try again.',
            style: const TextStyle(color: StoreColors.foregroundSubtle),
          ),
          const SizedBox(height: 12),
          Text(
            orderTransferFailureMessage(context, failure),
            style: const TextStyle(color: StoreColors.danger),
          ),
        ],
      );
}
