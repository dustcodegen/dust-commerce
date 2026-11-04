import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

const _orderHelpTextStyle = TextStyle(fontSize: 14, height: 24 / 14);

/// Source-shaped order help links with the visible order number prefilled.
final class CustomerServiceOrderHelp extends StatelessWidget {
  /// Creates support navigation for [orderReference].
  const CustomerServiceOrderHelp({required this.orderReference, super.key});

  /// Human-facing order number sent to the contact route.
  final String orderReference;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'shop_checkout_need_help',
            defaultText: 'Need help?',
            style: TextStyle(
              fontSize: 14,
              height: 24 / 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: StoreColors.foreground,
              textStyle: _orderHelpTextStyle,
            ),
            onPressed: () =>
                context.navigator.contact(orderReference: orderReference).go(),
            child: const TranslatedText(
              'shop_customer_service_contact',
              defaultText: 'Contact',
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: StoreColors.foreground,
              textStyle: _orderHelpTextStyle,
            ),
            onPressed: () =>
                context.navigator.contact(orderReference: orderReference).go(),
            child: const TranslatedText(
              'shop_account_returns_exchanges',
              defaultText: 'Returns & Exchanges',
            ),
          ),
        ],
      );
}
