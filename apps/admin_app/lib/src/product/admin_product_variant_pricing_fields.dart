part of 'admin_product_variant_pricing_page.dart';

final class _AdminVariantPricingBody extends StatelessWidget {
  const _AdminVariantPricingBody({
    required this.busy,
    required this.currencies,
    required this.failure,
    required this.formKey,
    required this.prices,
    required this.variant,
  });

  final bool busy;
  final List<String> currencies;
  final Option<String> failure;
  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> prices;
  final AdminProductVariant variant;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Variant prices',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set exact amounts for every active storefront currency.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _AdminVariantPricingGrid(
                        busy: busy,
                        currencies: currencies,
                        prices: prices,
                        variant: variant,
                      ),
                      if (failure case Some(value: final message)) ...[
                        const SizedBox(height: 16),
                        _AdminVariantPricingFailure(message: message),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

final class _AdminVariantPricingFailure extends StatelessWidget {
  const _AdminVariantPricingFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      );
}

final class _AdminVariantPricingGrid extends StatelessWidget {
  const _AdminVariantPricingGrid({
    required this.busy,
    required this.currencies,
    required this.prices,
    required this.variant,
  });

  final bool busy;
  final List<String> currencies;
  final Map<String, TextEditingController> prices;
  final AdminProductVariant variant;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: (320 + currencies.length * 180).clamp(680, 960).toDouble(),
            child: Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  child: Row(
                    children: [
                      const Expanded(flex: 2, child: Text('Title')),
                      for (final currency in currencies)
                        SizedBox(
                          width: 180,
                          child: Text(currency.toUpperCase()),
                        ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: Text(variant.title)),
                      for (final currency in currencies)
                        SizedBox(
                          width: 180,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: TextFormField(
                              key: ValueKey('variant-price-$currency'),
                              controller: prices[currency],
                              enabled: !busy,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                              ),
                              validator: (value) =>
                                  _validateAmount(value, currency),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

String? _validateAmount(String? value, String currency) =>
    value == null || parseMinorUnits(value, currency) == null
        ? 'Enter a valid price'
        : null;
