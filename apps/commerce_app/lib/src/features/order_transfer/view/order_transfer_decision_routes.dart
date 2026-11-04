import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:flutter/material.dart';

/// Source-compatible accept deep link for an emailed order-transfer capability.
@AppRoute(
  '/order/:id/transfer/:token/accept',
  name: 'orderTransferAccept',
  guards: [],
)
final class OrderTransferAcceptPage extends StatelessWidget {
  /// Creates the automatic accept decision page.
  const OrderTransferAcceptPage({
    required this.id,
    required this.token,
    super.key,
  });

  /// Order identifier named by the transfer link.
  final String id;

  /// Single-use transfer capability.
  final String token;

  @override
  Widget build(BuildContext context) => OrderTransferDecisionView(
        action: OrderTransferAction.accept,
        id: id,
        token: token,
      );
}

/// Source-compatible decline deep link for an emailed order-transfer capability.
@AppRoute(
  '/order/:id/transfer/:token/decline',
  name: 'orderTransferDecline',
  guards: [],
)
final class OrderTransferDeclinePage extends StatelessWidget {
  /// Creates the automatic decline decision page.
  const OrderTransferDeclinePage({
    required this.id,
    required this.token,
    super.key,
  });

  /// Order identifier named by the transfer link.
  final String id;

  /// Single-use transfer capability.
  final String token;

  @override
  Widget build(BuildContext context) => OrderTransferDecisionView(
        action: OrderTransferAction.decline,
        id: id,
        token: token,
      );
}
