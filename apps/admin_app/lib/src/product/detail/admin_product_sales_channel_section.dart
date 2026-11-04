import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped availability summary backed by explicit product links.
final class AdminProductSalesChannelSection extends StatelessWidget {
  /// Creates the read-only product channel section.
  const AdminProductSalesChannelSection({
    required this.channels,
    required this.totalChannels,
    required this.onEdit,
    super.key,
  });

  /// Channels explicitly attached to this product.
  final List<AdminSalesChannel> channels;

  /// Opens the full-screen channel assignment editor.
  final VoidCallback onEdit;

  /// Total configured channels when the supporting request succeeded.
  final Option<int> totalChannels;

  @override
  Widget build(BuildContext context) {
    final visible = channels.take(3).map((channel) => channel.name).toList();
    final hidden = channels.skip(3).map((channel) => channel.name).toList();
    return AdminProductDetailSection(
      title: 'Sales Channels',
      action: adminSectionAction(onEdit),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ChannelIcon(color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  visible.isEmpty ? 'Not configured' : visible.join(', '),
                  style: visible.isEmpty
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              ),
              if (hidden.isNotEmpty)
                Tooltip(
                  message: hidden.join('\n'),
                  child: Text(
                    '+${hidden.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text.rich(_availabilityText(context)),
        ],
      ),
    );
  }

  TextSpan _availabilityText(BuildContext context) => switch (totalChannels) {
        Some(value: final total) => TextSpan(
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            children: [
              const TextSpan(text: 'Available in '),
              _strong(context, '${channels.length}'),
              const TextSpan(text: ' of '),
              _strong(context, '$total'),
              const TextSpan(text: ' sales channels'),
            ],
          ),
        None() => TextSpan(
            text: 'Channel availability could not be loaded.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      };

  TextSpan _strong(BuildContext context, String text) => TextSpan(
        text: text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      );
}

final class _ChannelIcon extends StatelessWidget {
  const _ChannelIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(Icons.hub_outlined, size: 16, color: color),
      );
}
