import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Honest terminal state when every delivered unit is already in a return.
final class OrderReturnExhaustedState extends StatelessWidget {
  /// Creates the exhausted return state.
  const OrderReturnExhaustedState({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TranslatedText(
              'shop_account_return_no_items',
              defaultText: 'This order has no items left to return.',
              style: TextStyle(color: StoreColors.foregroundSubtle),
            ),
            const SizedBox(height: 12),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: context.readOrderReturnViewModel().close,
              child: const TranslatedText(
                'shop_cancel',
                defaultText: 'Close',
              ),
            ),
          ],
        ),
      );
}
