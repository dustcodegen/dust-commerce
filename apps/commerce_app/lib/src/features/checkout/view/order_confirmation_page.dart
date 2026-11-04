import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'order_confirmation_view.dart';

/// Source-compatible order confirmation, including guest receipt restoration.
@AppRoute('/order/:id/confirmed', name: 'orderConfirmed', guards: [])
final class OrderConfirmationPage extends StatefulWidget {
  /// Creates the confirmation route for [id].
  const OrderConfirmationPage({required this.id, super.key});

  /// Opaque completed-order identifier from the checkout redirect.
  final String id;

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(OrderConfirmationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) _load();
  }

  void _load() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(context.readCheckoutViewModel().loadReceipt(widget.id));
        }
      });

  @override
  Widget build(BuildContext context) {
    final state = context.watchCheckoutViewModel().value;
    final order = state.order;
    return StoreScaffold(
      body: order != null && order.id == widget.id
          ? OrderConfirmationView(order: order)
          : state.status == CheckoutStatus.failed
              ? _ReceiptFailure(message: state.message)
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

final class _ReceiptFailure extends StatelessWidget {
  const _ReceiptFailure({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message ??
                  context.tr(
                    'shop_checkout_receipt_not_found',
                    defaultText: 'Order confirmation not found.',
                  )),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.navigator.catalog().go(),
                child: const TranslatedText(
                  'shop_checkout_frontpage',
                  defaultText: 'Go to frontpage',
                ),
              ),
            ],
          ),
        ),
      );
}
