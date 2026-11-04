import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-authored public transfer explanation and decision content.
final class OrderTransferContent extends StatelessWidget {
  /// Creates content for one emailed order-transfer capability.
  const OrderTransferContent({
    required this.orderId,
    required this.token,
    required this.state,
    super.key,
  });

  /// Order named by the capability URL.
  final String orderId;

  /// Current decision state.
  final OrderTransferState state;

  /// Single-use capability passed only to the decision actions.
  final String token;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OrderTransferImage(),
          const SizedBox(height: 10),
          Text(
            context.tr(
              'shop_order_transfer_title',
              defaultText: 'Transfer request for order {id}',
              args: {'id': orderId},
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr(
              'shop_order_transfer_intro',
              defaultText: "You've received a request to transfer ownership "
                  'of your order ({id}). If you agree to this request, you can '
                  'approve the transfer by clicking the button below.',
              args: {'id': orderId},
            ),
            style: const TextStyle(
              color: StoreColors.foregroundSubtle,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          const TranslatedText(
            'shop_order_transfer_responsibility',
            defaultText: 'If you accept, the new owner will take over all '
                'responsibilities and permissions associated with this order.',
            style: TextStyle(
              color: StoreColors.foregroundSubtle,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const TranslatedText(
            'shop_order_transfer_ignore',
            defaultText: 'If you do not recognize this request or wish to '
                'retain ownership, no further action is required.',
            style: TextStyle(
              color: StoreColors.foregroundSubtle,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          OrderTransferActions(
            orderId: orderId,
            token: token,
            state: state,
          ),
        ],
      );
}
