import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's right-side product-type editor.
Future<AdminProductType?> showAdminProductTypeEditDrawer(
  BuildContext context,
  AdminProductType productType,
) =>
    showGeneralDialog<AdminProductType>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close product type editor',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.centerRight,
          child: _EditDrawer(productType: productType),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );

final class _EditDrawer extends StatefulWidget {
  const _EditDrawer({required this.productType});

  final AdminProductType productType;

  @override
  State<_EditDrawer> createState() => _EditDrawerState();
}

final class _EditDrawerState extends State<_EditDrawer> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _value;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _value = TextEditingController(text: widget.productType.value);
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
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width.clamp(0, 560).toDouble(),
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Expanded(
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text('Value',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _value,
                      autofocus: true,
                      enabled: !_busy,
                      validator: _validate,
                      onFieldSubmitted: (_) => _save(),
                    ),
                    if (state.failure case Some(value: final message)) ...[
                      const SizedBox(height: 16),
                      Text(message,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                  ],
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        height: 62,
        padding: const EdgeInsets.only(left: 24, right: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Text('Edit Product Type',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: _busy ? null : Navigator.of(context).pop,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ]),
      );

  Widget _footer() => Container(
        height: 62,
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
                : const Text('Save'),
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
    final updated = await context.readAdminProductTypeViewModel().update(
          widget.productType.id,
          AdminUpdateProductType(value: _value.text),
        );
    if (!mounted) return;
    switch (updated) {
      case Some(value: final productType):
        Navigator.of(context).pop(productType);
      case None():
        setState(() => _busy = false);
    }
  }
}
