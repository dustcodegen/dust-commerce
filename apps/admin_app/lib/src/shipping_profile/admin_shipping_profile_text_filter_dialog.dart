import 'package:flutter/material.dart';

/// Opens one dedicated text-filter editor.
Future<String?> showAdminShippingProfileTextFilterDialog(
  BuildContext context, {
  required String label,
  required String initialValue,
}) =>
    showDialog<String>(
      context: context,
      builder: (context) => AdminShippingProfileTextFilterDialog(
        label: label,
        initialValue: initialValue,
      ),
    );

/// Small editor used by name and type filters.
final class AdminShippingProfileTextFilterDialog extends StatefulWidget {
  /// Creates one text-filter editor.
  const AdminShippingProfileTextFilterDialog({
    required this.label,
    required this.initialValue,
    super.key,
  });

  /// Existing filter text.
  final String initialValue;

  /// Human-readable filter name.
  final String label;

  @override
  State<AdminShippingProfileTextFilterDialog> createState() =>
      _AdminShippingProfileTextFilterDialogState();
}

final class _AdminShippingProfileTextFilterDialogState
    extends State<AdminShippingProfileTextFilterDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Filter by ${widget.label.toLowerCase()}'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          onSubmitted: (_) => _apply(),
          decoration: InputDecoration(labelText: widget.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: _apply, child: const Text('Apply')),
        ],
      );

  void _apply() => Navigator.pop(context, _controller.text.trim());
}
