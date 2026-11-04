import 'package:admin_app/src/core/admin_money.dart';
import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_product_variant_pricing_fields.dart';
part 'admin_product_variant_pricing_page_chrome.dart';

/// Opens Medusa's full-screen variant-pricing focus surface.
Future<bool?> showAdminProductVariantPricingPage(
  BuildContext context,
  AdminProductDetail product,
  AdminProductVariant variant,
) async {
  final currencies =
      await context.readAdminProductDetailViewModel().pricingCurrencies();
  if (!context.mounted) return null;
  return switch (currencies) {
    Some(value: final values) => showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'Close price editor',
        transitionDuration: const Duration(milliseconds: 160),
        pageBuilder: (_, __, ___) => _VariantPricingPage(
          product: product,
          variant: variant,
          currencies: values,
        ),
      ),
    None() => null,
  };
}

final class _VariantPricingPage extends StatefulWidget {
  const _VariantPricingPage({
    required this.product,
    required this.variant,
    required this.currencies,
  });

  final List<String> currencies;
  final AdminProductDetail product;
  final AdminProductVariant variant;

  @override
  State<_VariantPricingPage> createState() => _VariantPricingPageState();
}

final class _VariantPricingPageState extends State<_VariantPricingPage> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _prices;

  @override
  void initState() {
    super.initState();
    final current = {
      for (final price in widget.variant.prices)
        price.currencyCode: price.amount,
    };
    _prices = {
      for (final currency in widget.currencies)
        currency: TextEditingController(
          text: switch (current[currency]) {
            final amount? => formatMinorUnits(amount, currency),
            null => '',
          },
        ),
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminProductDetailViewModel().clearFailure();
    });
  }

  @override
  void dispose() {
    for (final controller in _prices.values) {
      controller.dispose();
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
        child: Column(
          children: [
            _AdminVariantPricingHeader(
              busy: busy,
              onClose: () => Navigator.of(context).pop(false),
            ),
            Expanded(
              child: _AdminVariantPricingBody(
                busy: busy,
                currencies: widget.currencies,
                failure: state.failure,
                formKey: _form,
                prices: _prices,
                variant: widget.variant,
              ),
            ),
            _AdminVariantPricingFooter(
              busy: busy,
              onCancel: () => Navigator.of(context).pop(false),
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final request = AdminUpdateVariantPrices(prices: [
      for (final currency in widget.currencies)
        AdminUpdateVariantPrice(
          currencyCode: currency,
          amount: parseMinorUnits(_prices[currency]!.text, currency)!,
        ),
    ]);
    final saved = await context
        .readAdminProductDetailViewModel()
        .updateVariantPrices(widget.product.id, widget.variant.id, request);
    if (saved && mounted) Navigator.of(context).pop(true);
  }
}
