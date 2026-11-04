import 'package:admin_app/src/product_option/admin_product_option_detail_state.dart';
import 'package:admin_app/src/product_option/admin_product_option_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_product_option_edit_chrome.dart';
part 'admin_product_option_edit_fields.dart';

/// Opens Medusa's right-side product-option editor.
Future<String?> showAdminProductOptionEditDrawer(
  BuildContext context,
  AdminProductOptionDetail productOption,
) =>
    showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close product option editor',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.centerRight,
          child: _OptionEditDrawer(productOption: productOption),
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

final class _OptionEditDrawer extends StatefulWidget {
  const _OptionEditDrawer({required this.productOption});

  final AdminProductOptionDetail productOption;

  @override
  State<_OptionEditDrawer> createState() => _OptionEditDrawerState();
}

final class _OptionEditDrawerState extends State<_OptionEditDrawer> {
  final _form = GlobalKey<FormState>();
  final _pending = TextEditingController();
  late final TextEditingController _title;
  late List<String> _values;
  String? _valueError;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.productOption.title);
    _values = [for (final item in widget.productOption.values) item.value];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.readAdminProductOptionDetailViewModel().clearFailure();
      }
    });
  }

  @override
  void dispose() {
    _pending.dispose();
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductOptionDetailViewModel().value;
    final busy = state.isSaving;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width.clamp(0, 560).toDouble(),
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(busy),
            Expanded(
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: _fields(state, busy),
                ),
              ),
            ),
            _footer(busy),
          ],
        ),
      ),
    );
  }

  void _addValue() {
    final value = _pending.text.trim();
    if (value.isEmpty) return;
    if (_values.contains(value)) {
      setState(() => _valueError = 'Values must be unique');
      return;
    }
    setState(() {
      _values = [..._values, value];
      _pending.clear();
      _valueError = null;
    });
  }

  void _removeValue(String value) => setState(() {
        _values = _values.where((item) => item != value).toList();
        _valueError = _values.isEmpty ? 'At least one value is required' : null;
      });

  void _reorder(int oldIndex, int newIndex) => setState(() {
        final next = [..._values];
        next.insert(newIndex, next.removeAt(oldIndex));
        _values = next;
      });

  Future<void> _save() async {
    _addValue();
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_values.isEmpty) {
      setState(() => _valueError = 'At least one value is required');
      return;
    }
    final saved = await context.readAdminProductOptionDetailViewModel().update(
          widget.productOption.id,
          AdminUpdateProductOption(title: _title.text, values: _values),
        );
    if (saved && mounted) Navigator.of(context).pop(_title.text.trim());
  }
}
