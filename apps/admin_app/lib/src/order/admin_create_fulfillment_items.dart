import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Remaining order lines eligible for the selected shipping profile.
final class AdminCreateFulfillmentItems extends StatelessWidget {
  /// Creates source-faithful fulfillment item controls.
  const AdminCreateFulfillmentItems({
    required this.order,
    required this.remaining,
    required this.quantities,
    required this.shippingProfileId,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  /// Whether quantity inputs accept changes.
  final bool enabled;

  /// Receives one parsed line quantity.
  final void Function(String id, int quantity) onChanged;

  /// Complete order snapshot used for frozen labels and images.
  final AdminOrderDetail order;

  /// Current requested quantities keyed by line ID.
  final Map<String, int> quantities;

  /// Positive quantities not assigned to active fulfillments.
  final Map<String, int> remaining;

  /// Profile supported by the selected shipping method.
  final Option<String> shippingProfileId;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Items to fulfill',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          for (final item in order.items)
            if (remaining.containsKey(item.id))
              _FulfillmentItemCard(
                item: item,
                maximum: remaining[item.id]!,
                quantity: quantities[item.id] ?? 0,
                enabled: enabled,
                compatible: item.shippingProfileId == shippingProfileId &&
                    shippingProfileId is Some<String>,
                onChanged: onChanged,
              ),
        ],
      );
}

final class _FulfillmentItemCard extends StatelessWidget {
  const _FulfillmentItemCard({
    required this.item,
    required this.maximum,
    required this.quantity,
    required this.enabled,
    required this.compatible,
    required this.onChanged,
  });

  final bool compatible;
  final bool enabled;
  final AdminOrderItem item;
  final int maximum;
  final void Function(String id, int quantity) onChanged;
  final int quantity;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
          color: compatible
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
        child: Row(children: [
          _FulfillmentThumbnail(thumbnail: item.thumbnail),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (item.variantTitle case Some(:final value))
                  Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (!compatible)
                  Text(
                    'Not available for this shipping method',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 72,
            child: TextFormField(
              key: ValueKey((item.id, quantity, enabled)),
              initialValue: '$quantity',
              enabled: enabled && compatible,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => onChanged(
                item.id,
                int.tryParse(value) ?? 0,
              ),
            ),
          ),
          SizedBox(width: 56, child: Text(' / $maximum')),
        ]),
      );
}

final class _FulfillmentThumbnail extends StatelessWidget {
  const _FulfillmentThumbnail({required this.thumbnail});

  final Option<String> thumbnail;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox.square(
          dimension: 48,
          child: switch (thumbnail) {
            Some(:final value) => Image.network(
                value,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _FulfillmentImageFallback(),
              ),
            None() => const _FulfillmentImageFallback(),
          },
        ),
      );
}

final class _FulfillmentImageFallback extends StatelessWidget {
  const _FulfillmentImageFallback();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.inventory_2_outlined, size: 20),
      );
}
