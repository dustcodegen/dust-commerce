import 'package:admin_app/src/core/admin_country.dart';
import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_product_variant_edit_attributes.dart';
part 'admin_product_variant_edit_chrome.dart';
part 'admin_product_variant_edit_country_picker.dart';
part 'admin_product_variant_edit_field.dart';
part 'admin_product_variant_edit_fields.dart';
part 'admin_product_variant_edit_inventory.dart';
part 'admin_product_variant_edit_route.dart';
part 'admin_product_variant_edit_values.dart';

final class _VariantEditDrawerState extends State<_VariantEditDrawer> {
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  late final _VariantEditValues _values;
  late final Map<String, String> _selections;
  late bool _allowBackorder;
  late bool _manageInventory;
  late String? _originCountry;

  @override
  void initState() {
    super.initState();
    final variant = widget.variant;
    _values = _VariantEditValues(variant);
    _selections = {...variant.optionValues};
    _allowBackorder = variant.allowBackorder;
    _manageInventory = variant.manageInventory;
    _originCountry = variant.originCountry;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminProductDetailViewModel().clearFailure();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _values.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductDetailViewModel().value;
    final busy = state.isSaving;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          ),
        ),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width.clamp(0, 560).toDouble(),
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AdminVariantEditHeader(
                busy: busy,
                onClose: () => Navigator.of(context).pop(false),
              ),
              Expanded(
                child: _AdminVariantEditForm(
                  allowBackorder: _allowBackorder,
                  busy: busy,
                  failure: state.failure,
                  formKey: _form,
                  manageInventory: _manageInventory,
                  onAllowBackorderChanged: _setAllowBackorder,
                  onCountrySelected: _setOriginCountry,
                  onCountryTyped: _typeOriginCountry,
                  onManageInventoryChanged: _setManageInventory,
                  options: widget.product.options,
                  readOriginCountry: () => _originCountry,
                  scrollController: _scroll,
                  selections: _selections,
                  values: _values,
                ),
              ),
              _AdminVariantEditFooter(
                busy: busy,
                onCancel: () => Navigator.of(context).pop(false),
                onSave: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final saved = await context.readAdminProductDetailViewModel().updateVariant(
          widget.product.id,
          widget.variant.id,
          _values.request(
            allowBackorder: _allowBackorder,
            manageInventory: _manageInventory,
            optionValues: _selections,
            originCountry: _originCountry,
          ),
        );
    if (saved && mounted) Navigator.of(context).pop(true);
  }

  void _setAllowBackorder(bool value) => setState(() {
        _allowBackorder = value;
      });

  void _setManageInventory(bool value) => setState(() {
        _manageInventory = value;
      });

  void _setOriginCountry(String? value) => setState(() {
        _originCountry = value == null || value.isEmpty ? null : value;
        if (_originCountry == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _values.originCountry.clear();
          });
        }
      });

  void _typeOriginCountry(String value) {
    if (value != adminCountryName(_originCountry)) _originCountry = null;
  }
}
