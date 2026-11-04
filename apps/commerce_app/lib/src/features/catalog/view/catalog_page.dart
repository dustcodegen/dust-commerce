import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:dust_flutter/route.dart';
import 'package:flutter/material.dart';

import 'featured_product_rail_view.dart';
import 'home_hero.dart';

/// Home hero and collection rails translated from the Medusa DTC source.
@AppRoute('/', name: 'catalog', guards: [])
class CatalogPage extends StatefulWidget {
  /// Creates the storefront home.
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String? _currency;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currency = context.watchStoreShellViewModel().value.currencyCode;
    if (_currency == currency) return;
    _currency = currency;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(context.readCatalogViewModel().load(currency: currency));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchCatalogViewModel().value;
    return StoreScaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: HomeHero()),
          switch (state.status) {
            CatalogStatus.idle ||
            CatalogStatus.loading =>
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            CatalogStatus.failed => SliverFillRemaining(
                child: _Failure(
                  onRetry: () => context.readCatalogViewModel().load(),
                ),
              ),
            CatalogStatus.ready when state.isEmpty => const SliverFillRemaining(
                child: Center(
                  child: TranslatedText(
                    'shop_empty',
                    defaultText: 'Nothing for sale yet',
                  ),
                ),
              ),
            CatalogStatus.ready => SliverList.builder(
                itemCount: state.rails.length,
                itemBuilder: (context, index) => FeaturedProductRailView(
                  rail: state.rails[index],
                  currencyCode: state.currencyCode,
                ),
              ),
          },
          const SliverToBoxAdapter(child: StoreFooter()),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TranslatedText(
              'shop_catalog_failure',
              defaultText: 'Could not load the catalogue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const TranslatedText(
                'shop_retry',
                defaultText: 'Try again',
              ),
            ),
          ],
        ),
      );
}
