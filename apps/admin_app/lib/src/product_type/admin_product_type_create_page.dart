import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's full-screen product-type creation focus surface.
Future<AdminProductType?> showAdminProductTypeCreatePage(
        BuildContext context) =>
    showGeneralDialog<AdminProductType>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Create product type',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) => const _CreateForm(),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

final class _CreateForm extends StatefulWidget {
  const _CreateForm();

  @override
  State<_CreateForm> createState() => _CreateFormState();
}

final class _CreateFormState extends State<_CreateForm> {
  final _form = GlobalKey<FormState>();
  final _value = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminProductTypeViewModel().clearFailure();
    });
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductTypeViewModel().value;
    return PopScope(
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
                  child: SizedBox(
                    width: 768,
                    child: Form(
                      key: _form,
                      child: ListView(
                        padding: const EdgeInsets.all(40),
                        children: [
                          const SizedBox(height: 32),
                          Text(
                            'Create Product Type',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          const Text('Add a reusable product classification.'),
                          const SizedBox(height: 32),
                          Text('Value',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _value,
                            autofocus: true,
                            enabled: !_busy,
                            decoration:
                                const InputDecoration(hintText: 'Shirt'),
                            validator: _validate,
                            onFieldSubmitted: (_) => _save(),
                          ),
                          if (state.failure
                              case Some(value: final message)) ...[
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
  }

  Widget _header() => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
          IconButton(
            tooltip: 'Close',
            onPressed: _busy ? null : Navigator.of(context).pop,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
          const SizedBox(width: 6),
          Text('Create Product Type',
              style: Theme.of(context).textTheme.titleMedium),
        ]),
      );

  Widget _footer() => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: _busy ? null : Navigator.of(context).pop,
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
                : const Text('Create'),
          ),
        ]),
      );

  String? _validate(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Value is required';
    if (input.length > 255) return 'Use at most 255 characters';
    return null;
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final created = await context.readAdminProductTypeViewModel().create(
          AdminCreateProductType(value: _value.text),
        );
    if (!mounted) return;
    switch (created) {
      case Some(value: final productType):
        Navigator.of(context).pop(productType);
      case None():
        setState(() => _busy = false);
    }
  }
}
