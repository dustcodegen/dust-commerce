import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

const _previewThumbnailShadow = [
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

/// One item in the desktop navigation cart preview.
class CartPreviewLine extends StatelessWidget {
  /// Creates a compact preview line.
  const CartPreviewLine({
    required this.item,
    required this.state,
    required this.onClose,
    super.key,
  });

  /// Product snapshot held by the cart.
  final LineItem item;

  /// Closes the preview before product navigation.
  final VoidCallback onClose;

  /// Current mutation state.
  final CartState state;

  @override
  Widget build(BuildContext context) {
    final deleting = state.status == CartStatus.loading &&
        state.operation == CartOperation.remove &&
        state.activeLineId == item.id;
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => _product(context),
            child: SizedBox.square(
              dimension: 96,
              child: ProductImage(
                url: item.thumbnail,
                aspectRatio: 1,
                border: false,
                boxShadow: _previewThumbnailShadow,
                transitionDuration: const Duration(milliseconds: 150),
              ),
            ),
          ),
          // The source reserves a 122px image track around the 96px thumbnail,
          // followed by a 16px grid gap.
          const SizedBox(width: 42),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _product(context),
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 24 / 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatMoney(item.subtotal),
                      style: const TextStyle(
                        color: StoreColors.foregroundSubtle,
                        fontSize: 14,
                        height: 24 / 14,
                      ),
                    ),
                  ],
                ),
                if (item.variantTitle case final title?)
                  Text(
                    context.tr(
                      'shop_cart_variant',
                      defaultText: 'Variant: {name}',
                      args: {'name': title},
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: StoreColors.foregroundSubtle,
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                Text(
                  context.tr(
                    'shop_cart_preview_quantity',
                    defaultText: 'Quantity: {count}',
                    args: {'count': item.quantity},
                  ),
                  style: const TextStyle(fontSize: 14, height: 20 / 14),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: state.status == CartStatus.loading
                      ? null
                      : () => context.readCartViewModel().remove(item.id),
                  icon: deleting
                      ? const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline, size: 16),
                  label: const TranslatedText(
                    'shop_cart_remove',
                    defaultText: 'Remove',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: StoreColors.foregroundSubtle,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 12, height: 20 / 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _product(BuildContext context) {
    onClose();
    context.navigator.product(handle: item.productHandle).push();
  }
}
