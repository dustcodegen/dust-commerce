import 'package:admin_app/src/product_option/admin_product_option_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Full-screen product-option form matching Medusa's route focus modal.
final class AdminProductOptionCreateForm extends StatefulWidget {
  /// Creates the focused form.
  const AdminProductOptionCreateForm({super.key});
  @override
  State<AdminProductOptionCreateForm> createState() =>
      _AdminProductOptionCreateFormState();
}

final class _AdminProductOptionCreateFormState
    extends State<AdminProductOptionCreateForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _values = TextEditingController();
  bool _busy = false;
  String? _failure;
  @override
  void dispose() {
    _title.dispose();
    _values.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_busy,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 768),
                      child: Form(
                        key: _form,
                        child: ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 20),
                            Text('Create Product Option',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 4),
                            Text(
                                'Create a new product option and manage its values.',
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 32),
                            Text('Title',
                                style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _title,
                              enabled: !_busy,
                              decoration:
                                  const InputDecoration(hintText: 'Size'),
                              validator: _requiredTitle,
                            ),
                            const SizedBox(height: 16),
                            Text('Values',
                                style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _values,
                              enabled: !_busy,
                              decoration:
                                  const InputDecoration(hintText: 'S, M, L'),
                              validator: _requiredValues,
                            ),
                            if (_failure case final message?) ...[
                              const SizedBox(height: 16),
                              Text(message,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _footer(),
              ],
            ),
          ),
        ),
      );
  Widget _header() => Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
          const SizedBox(width: 18),
          IconButton(
            tooltip: 'Close',
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('esc', style: Theme.of(context).textTheme.labelSmall),
          ),
        ]),
      );
  Widget _footer() => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ]),
      );
  String? _requiredTitle(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Title is required' : null;
  String? _requiredValues(String? value) =>
      _parsedValues.isEmpty ? 'At least one value is required' : null;
  List<String> get _parsedValues => _values.text
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final values = _parsedValues;
    if (values.toSet().length != values.length) {
      setState(() => _failure = 'Values must be unique.');
      return;
    }
    setState(() {
      _busy = true;
      _failure = null;
    });
    final created = await context.readAdminProductOptionViewModel().create(
          AdminCreateProductOption(title: _title.text, values: values),
        );
    if (!mounted) return;
    switch (created) {
      case Some(value: final option):
        Navigator.of(context).pop(option);
      case None():
        setState(() {
          _busy = false;
          _failure = 'Unable to create this product option.';
        });
    }
  }
}
