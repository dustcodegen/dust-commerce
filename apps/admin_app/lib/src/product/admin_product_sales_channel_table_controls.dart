part of 'admin_product_sales_channel_editor.dart';

final class _ChannelStatus extends StatelessWidget {
  const _ChannelStatus({required this.disabled});

  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background =
        disabled ? colors.surfaceContainerHigh : colors.tertiaryContainer;
    final foreground =
        disabled ? colors.onSurfaceVariant : colors.onTertiaryContainer;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          disabled ? 'Disabled' : 'Enabled',
          style: TextStyle(color: foreground),
        ),
      ),
    );
  }
}

final class _SalesChannelPagination extends StatelessWidget {
  const _SalesChannelPagination({
    required this.page,
    required this.busy,
    required this.onPage,
  });

  final bool busy;
  final ValueChanged<int> onPage;
  final AdminSalesChannelDetailList page;

  @override
  Widget build(BuildContext context) {
    final start = page.count == 0 ? 0 : page.offset + 1;
    final end = (page.offset + page.salesChannels.length).clamp(0, page.count);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(children: [
        Text('$start-$end of ${page.count}'),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed: busy || page.offset == 0
              ? null
              : () => onPage((page.offset - page.limit).clamp(0, page.count)),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: busy || page.offset + page.limit >= page.count
              ? null
              : () => onPage(page.offset + page.limit),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ]),
    );
  }
}

final class _SalesChannelFailure extends StatelessWidget {
  const _SalesChannelFailure(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(message),
      );
}
