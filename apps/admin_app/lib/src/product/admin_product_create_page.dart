import 'package:admin_app/src/core/admin_money.dart';
import 'package:admin_app/src/product/admin_product_create_state.dart';
import 'package:admin_app/src/product/admin_product_create_view_model.dart';
import 'package:admin_app/src/product/admin_product_option_permutations.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

part 'admin_product_create_body.dart';
part 'admin_product_create_details.dart';
part 'admin_product_create_footer.dart';
part 'admin_product_create_form_fields.dart';
part 'admin_product_create_header.dart';
part 'admin_product_create_media_actions.dart';
part 'admin_product_create_media_view.dart';
part 'admin_product_create_options.dart';
part 'admin_product_create_submit.dart';
part 'admin_product_create_sync.dart';
part 'admin_product_create_variant.dart';

/// Opens Medusa's full-screen product creation focus surface.
Future<Option<AdminProductDetail>> showAdminProductCreatePage(
  BuildContext context,
) async {
  final product = await showGeneralDialog<AdminProductDetail>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Create product',
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const AdminProductCreatePage(),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
  return product == null ? const None<AdminProductDetail>() : Some(product);
}

/// Responsive three-step product form backed by the real admin API.
final class AdminProductCreatePage extends StatefulWidget {
  /// Creates the product focus surface.
  const AdminProductCreatePage({super.key});

  @override
  State<AdminProductCreatePage> createState() => _AdminProductCreatePageState();
}

final class _AdminProductCreatePageState extends State<AdminProductCreatePage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  final _handle = TextEditingController();
  final _description = TextEditingController();
  final _material = TextEditingController();
  final _options = <_OptionDraft>[];
  final _media = <_UploadedMediaDraft>[];
  final _variants = <_VariantDraft>[];
  final _variantDrafts = <String, _VariantDraft>{};

  var _step = 0;
  String? _typeId;
  var _discountable = true;
  var _hasVariants = true;
  var _handleEdited = false;
  var _discarding = false;

  @override
  void initState() {
    super.initState();
    _options.add(_OptionDraft(
      title: 'Default option',
      values: 'Default option value',
      onChanged: _syncVariants,
    ));
    _syncVariants();
    _title.addListener(_syncHandle);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminProductCreateViewModel().load();
    });
  }

  @override
  void dispose() {
    _title
      ..removeListener(_syncHandle)
      ..dispose();
    _subtitle.dispose();
    _handle.dispose();
    _description.dispose();
    _material.dispose();
    for (final option in _options) {
      option.dispose();
    }
    for (final variant in _variantDrafts.values) {
      variant.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductCreateViewModel().value;
    final busy = state.isBusy || _discarding;
    return PopScope(
      canPop: !busy && _media.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !busy) _cancel();
      },
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              _CreateHeader(
                step: _step,
                saving: busy,
                onStep: (step) => setState(() => _step = step),
                onClose: busy ? null : () => _cancel(),
              ),
              Expanded(child: _body(state)),
              _CreateFooter(
                step: _step,
                saving: busy,
                onCancel: busy ? null : () => _cancel(),
                onDraft:
                    busy ? null : () => _submit(AdminProductLifecycle.draft),
                onPrimary: busy
                    ? null
                    : () {
                        if (_step < 2) {
                          setState(() => _step++);
                        } else {
                          _submit(AdminProductLifecycle.published);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _rebuild(VoidCallback mutation) => setState(mutation);
}
