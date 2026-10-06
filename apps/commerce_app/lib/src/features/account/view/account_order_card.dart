import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

const _orderCardMetaStyle = TextStyle(fontSize: 12);

/// Source-shaped summary for one completed or pending customer order.
class AccountOrderCard extends StatelessWidget {
  /// Creates an order card.
  const AccountOrderCard({required this.order, super.key});

  /// Frozen server order.
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '#${order.displayId}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                formatStoreDate(
                  MaterialLocalizations.of(context),
                  order.placedAt,
                ),
                style: _orderCardMetaStyle,
              ),
              const SizedBox(width: 8),
              const _OrderMetaDivider(),
              const SizedBox(width: 8),
              Text(formatMoney(order.total), style: _orderCardMetaStyle),
              const SizedBox(width: 8),
              const _OrderMetaDivider(),
              const SizedBox(width: 8),
              Text(
                order.itemCount == 1
                    ? context.tr(
                        'shop_account_order_item',
                        defaultText: '{count} item',
                        args: {'count': order.itemCount},
                      )
                    : context.tr(
                        'shop_account_order_items',
                        defaultText: '{count} items',
                        args: {'count': order.itemCount},
                      ),
                style: _orderCardMetaStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final item in order.items.take(3))
                SizedBox(
                  width: 144,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductImage(url: item.thumbnail, aspectRatio: 1),
                      const SizedBox(height: 8),
                      Text(
                        '${item.title} × ${item.quantity}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (order.items.length > 4)
                SizedBox(
                  width: 144,
                  height: 144,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+ ${order.itemCount - 4}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const TranslatedText(
                          'shop_more',
                          defaultText: 'more',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () =>
                  context.navigator.accountOrderDetail(id: order.id).go(),
              child: const TranslatedText(
                'shop_account_see_details',
                defaultText: 'See details',
              ),
            ),
          ),
        ],
      );
}

final class _OrderMetaDivider extends StatelessWidget {
  const _OrderMetaDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 16,
        color: StoreColors.border,
      );
}
