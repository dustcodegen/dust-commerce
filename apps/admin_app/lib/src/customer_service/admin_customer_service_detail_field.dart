import 'package:flutter/material.dart';

/// One label/value pair in a support-request detail surface.
final class AdminCustomerServiceDetailField extends StatelessWidget {
  /// Creates a merchant-visible detail field.
  const AdminCustomerServiceDetailField({
    required this.label,
    required this.value,
    super.key,
  });

  /// Field meaning.
  final String label;

  /// Request value or an explicit absence marker.
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            SelectableText(value),
          ],
        ),
      );
}
