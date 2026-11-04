import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Intact and damaged quantity inputs for one requested return item.
final class AdminReturnItemFields extends StatelessWidget {
  /// Creates one labeled return-item input row.
  const AdminReturnItemFields({
    required this.title,
    required this.remaining,
    required this.intact,
    required this.damaged,
    super.key,
  });

  /// Damaged units received now.
  final TextEditingController damaged;

  /// Intact units received now.
  final TextEditingController intact;

  /// Units still eligible for receipt.
  final int remaining;

  /// Frozen order-line title.
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(child: Text('$title\n$remaining requested')),
          const SizedBox(width: 12),
          _QuantityField(label: 'Received', controller: intact),
          const SizedBox(width: 8),
          _QuantityField(label: 'Damaged', controller: damaged),
        ]),
      );
}

final class _QuantityField extends StatelessWidget {
  const _QuantityField({required this.label, required this.controller});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 104,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.end,
        ),
      );
}
