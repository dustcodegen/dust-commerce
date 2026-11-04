part of 'admin_product_table.dart';

final class _ProductHeader extends StatelessWidget {
  const _ProductHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(
          children: [
            Expanded(child: Text('Product')),
            Expanded(child: Text('Collection')),
            Expanded(child: Text('Sales Channels')),
            Expanded(child: Text('Variants')),
            Expanded(child: Text('Status')),
            SizedBox(width: 32),
          ],
        ),
      );
}
