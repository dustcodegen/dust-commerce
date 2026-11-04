import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

const _orderCardSmallStyle = TextStyle(
  fontSize: 12,
  height: 20 / 12,
  color: StoreColors.foreground,
);

const _orderCardThumbnailShadow = [
  BoxShadow(color: Color(0x14000000), spreadRadius: 1),
  BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: -1,
  ),
  BoxShadow(
    color: Color(0x0a000000),
    offset: Offset(0, 2),
    blurRadius: 4,
  ),
];

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
            '#${order.displayId}'.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                formatStoreDate(
                  MaterialLocalizations.of(context),
                  order.placedAt,
                ),
                style: _orderCardSmallStyle,
              ),
              const SizedBox(width: 8),
              const _OrderMetaDivider(),
              const SizedBox(width: 8),
              Text(formatMoney(order.total), style: _orderCardSmallStyle),
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
                style: _orderCardSmallStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1024 ? 4 : 2;
              final tileWidth =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final item in order.items.take(3))
                    SizedBox(
                      width: tileWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductImage(
                            url: item.thumbnail,
                            aspectRatio: 9 / 16,
                            border: false,
                            borderRadius: 16,
                            boxShadow: _orderCardThumbnailShadow,
                            transitionDuration:
                                const Duration(milliseconds: 150),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _orderCardSmallStyle.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.tr(
                                  'shop_account_order_quantity_separator',
                                  defaultText: 'x',
                                ),
                                style: _orderCardSmallStyle,
                              ),
                              Text('${item.quantity}',
                                  style: _orderCardSmallStyle),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (order.items.length > 4)
                    SizedBox(
                      width: tileWidth,
                      height: tileWidth,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+ ${order.itemCount - 4}',
                              style: _orderCardSmallStyle,
                            ),
                            const TranslatedText(
                              'shop_more',
                              defaultText: 'more',
                              style: _orderCardSmallStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
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
        height: 20,
        color: StoreColors.border,
      );
}
