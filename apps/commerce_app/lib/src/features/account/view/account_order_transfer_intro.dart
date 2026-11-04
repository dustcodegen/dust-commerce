import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa-authored explanation beside the order-transfer request form.
final class AccountOrderTransferIntro extends StatelessWidget {
  /// Creates the order-transfer introduction.
  const AccountOrderTransferIntro({super.key});

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            'shop_account_order_transfers',
            defaultText: 'Order transfers',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          TranslatedText(
            'shop_account_order_transfers_body',
            defaultText: "Can't find the order you are looking for?\n"
                'Connect an order to your account.',
            style: TextStyle(color: StoreColors.foregroundMuted),
          ),
        ],
      );
}
