import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'cart_quantity_control.dart';

const _lineThumbnailShadow = [
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

/// One source-faithful cart table row.
class CartLineItem extends StatelessWidget {
  /// Creates a cart row.
  const CartLineItem({
    required this.item,
    required this.state,
    required this.wide,
    required this.showDivider,
    super.key,
  });

  /// Snapshotted product line.
  final LineItem item;

  /// Current cart mutation state.
  final CartState state;

  /// Whether all source table columns fit.
  final bool wide;

  /// Whether this non-final row retains the source table divider.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final busy = state.status == CartStatus.loading;
    final active = busy && state.activeLineId == item.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _LineImage(item: item, wide: wide),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: wide ? 22 : 8),
                  child: _LineIdentity(item: item),
                ),
              ),
              SizedBox(
                width: wide ? 168 : 112,
                child: CartQuantityControl(
                  item: item,
                  enabled: !busy,
                  active: active,
                ),
              ),
              if (wide)
                SizedBox(
                  width: 80,
                  child: Text(
                    formatMoney(item.unitPrice),
                    style: const TextStyle(
                      color: StoreColors.foregroundMuted,
                      fontSize: 14,
                      height: 24 / 14,
                    ),
                  ),
                ),
              SizedBox(
                width: 88,
                child: Text(
                  formatMoney(item.subtotal),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: StoreColors.foregroundSubtle,
                    fontSize: 14,
                    height: 24 / 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.status == CartStatus.failed && state.activeLineId == item.id)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              state.message ??
                  context.tr(
                    'shop_cart_update_failed',
                    defaultText: 'Could not update this item.',
                  ),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (showDivider) const Divider(),
      ],
    );
  }
}

class _LineImage extends StatelessWidget {
  const _LineImage({required this.item, required this.wide});

  final LineItem item;
  final bool wide;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: wide ? 104 : 64,
        child: Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () =>
                context.navigator.product(handle: item.productHandle).push(),
            child: SizedBox(
              width: wide ? 96 : 48,
              child: ProductImage(
                url: item.thumbnail,
                aspectRatio: 1,
                border: false,
                boxShadow: _lineThumbnailShadow,
                transitionDuration: const Duration(milliseconds: 150),
              ),
            ),
          ),
        ),
      );
}

class _LineIdentity extends StatelessWidget {
  const _LineIdentity({required this.item});

  final LineItem item;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (item.variantTitle case final title?)
            Text(
              context.tr(
                'shop_cart_variant',
                defaultText: 'Variant: {name}',
                args: {'name': title},
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StoreColors.foregroundSubtle,
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
        ],
      );
}
