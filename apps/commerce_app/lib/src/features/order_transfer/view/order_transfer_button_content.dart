import 'package:flutter/material.dart';

/// Label or pending indicator inside one transfer decision action.
final class OrderTransferButtonContent extends StatelessWidget {
  /// Creates content for one transfer decision button.
  const OrderTransferButtonContent({
    required this.active,
    required this.label,
    super.key,
  });

  /// Whether this action owns the in-flight request.
  final bool active;

  /// Customer-facing decision label.
  final String label;

  @override
  Widget build(BuildContext context) => active
      ? const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Text(label);
}
