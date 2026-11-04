import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// One source-width delivery fact group on an order receipt.
final class OrderDeliveryDetail extends StatelessWidget {
  /// Creates a titled group of immutable receipt lines.
  const OrderDeliveryDetail({
    required this.title,
    required this.lines,
    super.key,
  });

  /// Frozen values shown under the heading.
  final List<String> lines;

  /// Customer-facing group heading.
  final String title;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            for (final line in lines)
              Text(
                line,
                style: const TextStyle(color: StoreColors.foregroundSubtle),
              ),
          ],
        ),
      );
}
