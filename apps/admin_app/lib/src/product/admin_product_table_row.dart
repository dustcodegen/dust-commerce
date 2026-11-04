part of 'admin_product_table.dart';

final class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.onDelete,
    required this.onOpen,
    required this.product,
  });

  final ValueChanged<AdminProduct>? onDelete;
  final ValueChanged<String> onOpen;
  final AdminProduct product;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onOpen(product.id),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _ProductThumbnail(url: product.thumbnail),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _MutedProductCell(value: product.collectionTitle),
                ),
                Expanded(
                  child: AdminProductSalesChannelCell(
                    channels: product.salesChannels,
                  ),
                ),
                Expanded(child: Text('${product.variantCount}')),
                Expanded(child: _ProductStatusCell(value: product.status)),
                SizedBox(
                  width: 32,
                  child: _ProductRowActions(
                    onDelete: onDelete,
                    onOpen: onOpen,
                    product: product,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
