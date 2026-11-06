import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Values returned by the create/edit refund-reason form.
final class AdminRefundReasonFormResult {
  /// Creates normalized form values.
  const AdminRefundReasonFormResult({
    required this.label,
    required this.code,
    required this.description,
  });

  /// Merchant-facing label.
  final String label;

  /// Stable machine code.
  final String code;

  /// Optional merchant guidance.
  final String? description;
}

/// Compact create/edit form for one refund reason.
final class AdminRefundReasonDialog extends StatefulWidget {
  /// Creates the form, optionally seeded from [reason].
  const AdminRefundReasonDialog({this.reason, super.key});

  /// Existing row being edited.
  final AdminRefundReason? reason;

  @override
  State<AdminRefundReasonDialog> createState() =>
      _AdminRefundReasonDialogState();
}

final class _AdminRefundReasonDialogState
    extends State<AdminRefundReasonDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _label;
  late final TextEditingController _code;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final reason = widget.reason;
    _label = TextEditingController(text: reason?.label ?? '');
    _code = TextEditingController(text: reason?.code ?? '');
    _description = TextEditingController(
      text: reason?.description.match(some: (value) => value, none: () => '') ??
          '',
    );
  }

  @override
  void dispose() {
    _label.dispose();
    _code.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.reason == null
            ? 'Create refund reason'
            : 'Edit refund reason'),
        content: Form(
          key: _form,
          child: SizedBox(
            width: 420,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: _label,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Label'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a label'
                    : null,
              ),
              TextFormField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (value) => _validCode(value),
              ),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Description (optional)'),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      );

  String? _validCode(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) return 'Enter a code';
    if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(code)) {
      return 'Use lowercase letters, numbers, _ or -';
    }
    return null;
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final description = _description.text.trim();
    Navigator.of(context).pop(AdminRefundReasonFormResult(
      label: _label.text.trim(),
      code: _code.text.trim(),
      description: description.isEmpty ? null : description,
    ));
  }
}
