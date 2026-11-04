import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Product-table channel labels matching Medusa's two-name display limit.
({String names, List<AdminSalesChannel> overflow})
    adminProductSalesChannelPresentation(List<AdminSalesChannel> channels) => (
          names: channels.take(2).map((channel) => channel.name).join(', '),
          overflow: List.unmodifiable(channels.skip(2)),
        );

/// Compact product-list cell with complete overflow names in a tooltip.
final class AdminProductSalesChannelCell extends StatelessWidget {
  /// Creates one channel availability cell.
  const AdminProductSalesChannelCell({required this.channels, super.key});

  /// Active channel objects from the product-list response.
  final List<AdminSalesChannel> channels;

  @override
  Widget build(BuildContext context) {
    final presentation = adminProductSalesChannelPresentation(channels);
    if (presentation.names.isEmpty) {
      return Text(
        '—',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }
    if (presentation.overflow.isEmpty) {
      return Tooltip(
        message: presentation.names,
        child: Text(presentation.names, overflow: TextOverflow.ellipsis),
      );
    }
    final overflowNames =
        presentation.overflow.map((channel) => channel.name).join('\n');
    return Row(
      children: [
        Flexible(
          child: Text(presentation.names, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: overflowNames,
          child: Text(
            '+${presentation.overflow.length} more',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
