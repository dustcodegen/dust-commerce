part of 'admin_product_sales_channel_editor.dart';

final class _SalesChannelTable extends StatelessWidget {
  const _SalesChannelTable({
    required this.page,
    required this.selected,
    required this.busy,
    required this.loading,
    required this.horizontal,
    required this.onToggle,
    required this.onTogglePage,
  });

  final bool busy;
  final ScrollController horizontal;
  final bool loading;
  final ValueChanged<String> onToggle;
  final ValueChanged<bool> onTogglePage;
  final AdminSalesChannelDetailList page;
  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    if (page.salesChannels.isEmpty && !loading) {
      return Center(
        child: Text(
          'No sales channels found',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    return Scrollbar(
      controller: horizontal,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: horizontal,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1080,
          child: Column(children: [
            _SalesChannelHeader(
              channels: page.salesChannels,
              selected: selected,
              busy: busy,
              onTogglePage: onTogglePage,
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final channel in page.salesChannels)
                    _SalesChannelRow(
                      channel: channel,
                      selected: selected.contains(channel.id),
                      busy: busy,
                      onToggle: () => onToggle(channel.id),
                    ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

final class _SalesChannelHeader extends StatelessWidget {
  const _SalesChannelHeader({
    required this.channels,
    required this.selected,
    required this.busy,
    required this.onTogglePage,
  });

  final bool busy;
  final List<AdminSalesChannelDetail> channels;
  final ValueChanged<bool> onTogglePage;
  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    final selectedCount =
        channels.where((row) => selected.contains(row.id)).length;
    final all = channels.isNotEmpty && selectedCount == channels.length;
    final some = selectedCount > 0 && !all;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Row(children: [
        SizedBox(
          width: 44,
          child: Checkbox(
            tristate: true,
            value: all
                ? true
                : some
                    ? null
                    : false,
            onChanged: busy ? null : (_) => onTogglePage(!all),
          ),
        ),
        const SizedBox(width: 180, child: Text('Name')),
        const SizedBox(width: 260, child: Text('Description')),
        const SizedBox(width: 120, child: Text('Status')),
        const SizedBox(width: 190, child: Text('Created At')),
        const SizedBox(width: 190, child: Text('Updated At')),
      ]),
    );
  }
}

final class _SalesChannelRow extends StatelessWidget {
  const _SalesChannelRow({
    required this.channel,
    required this.selected,
    required this.busy,
    required this.onToggle,
  });

  final bool busy;
  final AdminSalesChannelDetail channel;
  final VoidCallback onToggle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final description = switch (channel.description) {
      Some(:final value) => value,
      None() => '—',
    };
    final descriptionText = Text(
      description,
      overflow: TextOverflow.ellipsis,
    );
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(children: [
        SizedBox(
          width: 44,
          child: Checkbox(
            value: selected,
            onChanged: busy ? null : (_) => onToggle(),
          ),
        ),
        SizedBox(
          width: 180,
          child: Text(channel.name, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(
          width: 260,
          child: description == '—'
              ? descriptionText
              : Tooltip(message: description, child: descriptionText),
        ),
        SizedBox(
          width: 120,
          child: _ChannelStatus(disabled: channel.isDisabled),
        ),
        SizedBox(width: 190, child: Text(_salesChannelDate(channel.createdAt))),
        SizedBox(width: 190, child: Text(_salesChannelDate(channel.updatedAt))),
      ]),
    );
  }
}

String _salesChannelDate(DateTime value) =>
    DateFormat('MMM d, yyyy HH:mm').format(value.toLocal());
