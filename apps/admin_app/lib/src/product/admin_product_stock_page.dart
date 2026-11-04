import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_product_stock_failure.dart';
part 'admin_product_stock_page_chrome.dart';
part 'admin_product_stock_table.dart';

/// Opens Medusa's full-screen product stock focus surface.
Future<bool?> showAdminProductStockPage(
  BuildContext context,
  AdminProductDetail product,
) =>
    showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Close stock editor',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (_, __, ___) => _ProductStockPage(product: product),
    );

final class _ProductStockPage extends StatefulWidget {
  const _ProductStockPage({required this.product});

  final AdminProductDetail product;

  @override
  State<_ProductStockPage> createState() => _ProductStockPageState();
}

final class _ProductStockPageState extends State<_ProductStockPage> {
  final _form = GlobalKey<FormState>();
  late final List<_StockDraft> _drafts;

  @override
  void initState() {
    super.initState();
    _drafts = [
      for (final variant in widget.product.variants) _StockDraft(variant)
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminProductDetailViewModel().clearFailure();
    });
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.quantity.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductDetailViewModel().value;
    final busy = state.isSaving;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(children: [
          _AdminProductStockHeader(
            busy: busy,
            onClose: () => Navigator.of(context).pop(false),
          ),
          Expanded(
            child: _AdminProductStockBody(
              busy: busy,
              drafts: _drafts,
              failure: state.failure,
              formKey: _form,
              onManagedChanged: _setManaged,
            ),
          ),
          _AdminProductStockFooter(
            busy: busy,
            onCancel: () => Navigator.of(context).pop(false),
            onSave: _save,
          ),
        ]),
      ),
    );
  }

  void _setManaged(_StockDraft draft, {required bool managed}) =>
      setState(() => draft.managed = managed);

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final saved =
        await context.readAdminProductDetailViewModel().updateProductStock(
            widget.product.id,
            AdminUpdateProductStock(
              variants: [for (final draft in _drafts) draft.request],
            ));
    if (saved && mounted) Navigator.of(context).pop(true);
  }
}

final class _StockDraft {
  _StockDraft(this.variant)
      : managed = variant.manageInventory,
        quantity = TextEditingController(
          text: variant.inventoryQuantity.toString(),
        );

  bool managed;
  final TextEditingController quantity;
  final AdminProductVariant variant;

  AdminUpdateVariantStock get request => AdminUpdateVariantStock(
        id: variant.id,
        inventoryQuantity: int.parse(quantity.text),
        manageInventory: managed,
      );
}
