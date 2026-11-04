import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Product details translated from Medusa DTC ProductTemplate.
@AppRoute('/products/:handle', name: 'product', guards: [])
class ProductPage extends StatefulWidget {
  /// Creates a product route.
  const ProductPage({required this.handle, super.key});

  /// The stable product handle from the URL.
  final String handle;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? _currency;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currency = context.watchStoreShellViewModel().value.currencyCode;
    if (_currency == currency) return;
    _currency = currency;
    _loadAfterFrame(currency);
  }

  @override
  void didUpdateWidget(ProductPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handle != widget.handle) {
      _loadAfterFrame(
        _currency ?? context.readStoreShellViewModel().state.currencyCode,
      );
    }
  }

  void _loadAfterFrame(String currency) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(
          context.readProductViewModel().load(
                widget.handle,
                currency: currency,
                variantId: context.productVariantId,
              ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchProductViewModel().value;
    return StoreScaffold(
      body: switch (state.status) {
        ProductDetailStatus.idle ||
        ProductDetailStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        ProductDetailStatus.missing => const StoreMainNotFound(),
        ProductDetailStatus.failed => _Failure(message: state.message!),
        ProductDetailStatus.ready => ProductLayout(state: state),
      },
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.navigator.catalog().go(),
              child: const TranslatedText('shop_back_to_store',
                  defaultText: 'Back to store'),
            ),
          ],
        ),
      );
}
