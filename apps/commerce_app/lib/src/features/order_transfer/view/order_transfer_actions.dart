import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'order_transfer_button_content.dart';

/// Source-shaped accept and decline controls for an emailed capability.
final class OrderTransferActions extends StatelessWidget {
  /// Creates decision controls for [orderId] without storing [token] in state.
  const OrderTransferActions({
    required this.orderId,
    required this.token,
    required this.state,
    super.key,
  });

  /// Order named by the capability URL.
  final String orderId;

  /// Current action state.
  final OrderTransferState state;

  /// Single-use capability retained only by the route widget.
  final String token;

  @override
  Widget build(BuildContext context) {
    final succeeded = state.status == OrderTransferActionStatus.succeeded;
    final pending = state.status == OrderTransferActionStatus.pending;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (succeeded)
          Semantics(
            liveRegion: true,
            child: Text(
              _successMessage(context),
              style: const TextStyle(color: StoreColors.success),
            ),
          )
        else
          Row(
            children: [
              Flexible(
                child: FilledButton(
                  style: _largeButtonStyle(),
                  onPressed: pending ? null : () => _accept(context),
                  child: OrderTransferButtonContent(
                    active: pending &&
                        state.action == const Some(OrderTransferAction.accept),
                    label: context.tr(
                      'shop_order_transfer_accept',
                      defaultText: 'Accept transfer',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: OutlinedButton(
                  style: _largeButtonStyle(),
                  onPressed: pending ? null : () => _decline(context),
                  child: OrderTransferButtonContent(
                    active: pending &&
                        state.action == const Some(OrderTransferAction.decline),
                    label: context.tr(
                      'shop_order_transfer_decline',
                      defaultText: 'Decline transfer',
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (state.status == OrderTransferActionStatus.failed) ...[
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              orderTransferFailureMessage(context, state.failure),
              style: const TextStyle(color: StoreColors.danger),
            ),
          ),
        ],
      ],
    );
  }

  ButtonStyle _largeButtonStyle() => const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(0, 48)),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24),
        ),
        textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 18)),
      );

  String _successMessage(BuildContext context) =>
      state.action == const Some(OrderTransferAction.decline)
          ? context.tr(
              'shop_order_transfer_declined',
              defaultText: 'Order transfer declined successfully!',
            )
          : context.tr(
              'shop_order_transfer_accepted',
              defaultText: 'Order transferred successfully!',
            );

  void _accept(BuildContext context) => unawaited(
        context.readOrderTransferViewModel().accept(orderId, token),
      );

  void _decline(BuildContext context) => unawaited(
        context.readOrderTransferViewModel().decline(orderId, token),
      );
}

/// Localized public error that never echoes server or capability details.
String orderTransferFailureMessage(
  BuildContext context,
  Option<OrderTransferFailure> failure,
) =>
    failure.match(
      some: (value) => switch (value) {
        OrderTransferFailure.invalidRequest => context.tr(
            'shop_order_transfer_invalid_request',
            defaultText: 'Check the order ID and try again.',
          ),
        OrderTransferFailure.unauthorized => context.tr(
            'shop_order_transfer_session_expired',
            defaultText: 'Your session has expired. Please sign in again.',
          ),
        OrderTransferFailure.unavailable => context.tr(
            'shop_order_transfer_unavailable',
            defaultText: 'This transfer link is invalid or has expired.',
          ),
        OrderTransferFailure.orderUnavailable => context.tr(
            'shop_order_transfer_order_unavailable',
            defaultText: 'This order can no longer be transferred.',
          ),
        OrderTransferFailure.conflict => context.tr(
            'shop_order_transfer_conflict',
            defaultText: 'This transfer already has a different decision.',
          ),
        OrderTransferFailure.deliveryUnavailable => context.tr(
            'shop_order_transfer_delivery_unavailable',
            defaultText: 'Transfer email is unavailable. Please try later.',
          ),
        OrderTransferFailure.retryable => context.tr(
            'shop_order_transfer_failed',
            defaultText: 'We could not update the transfer. Please try again.',
          ),
      },
      none: () => context.tr(
        'shop_order_transfer_failed',
        defaultText: 'We could not update the transfer. Please try again.',
      ),
    );
