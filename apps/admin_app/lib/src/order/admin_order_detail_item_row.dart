import 'package:admin_app/src/core/admin_money.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// One Medusa-shaped frozen line in an order summary.
final class AdminOrderDetailItemRow extends StatelessWidget {
  /// Creates one line-item row.
  const AdminOrderDetailItemRow({required this.item, super.key});

  /// Frozen item response.
  final AdminOrderItem item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            _Thumbnail(source: item.thumbnail),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title),
                  if (item.variantTitle case Some(:final value))
                    Text(
                      value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Text(formatMinorUnits(item.unitAmount, item.currencyCode)),
            const SizedBox(width: 24),
            SizedBox(width: 34, child: Text('${item.quantity}x')),
            SizedBox(
              width: 90,
              child: Text(
                formatMinorUnits(
                  item.unitAmount * item.quantity,
                  item.currencyCode,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
}

final class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.source});

  final Option<String> source;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox.square(
          dimension: 40,
          child: switch (source) {
            Some(:final value) => Image.network(
                value,
                fit: BoxFit.cover,
                // Medusa's public seed CDN omits CORS headers on web.
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (context, error, stackTrace) =>
                    const _ImageFallback(),
              ),
            None() => const _ImageFallback(),
          },
        ),
      );
}

final class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: const Center(child: Icon(Icons.image_outlined, size: 17)),
      );
}
