import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import '../../checkout/view/checkout_scaffold.dart';

/// Atomic checkout-permalink entry point copied from the current DTC source.
@AppRoute('/buy/:items', name: 'buy', guards: [])
final class BuyPage extends StatefulWidget {
  /// Creates a checkout-permalink route.
  const BuyPage({required this.items, super.key});

  /// Encoded `variant_id:quantity` pairs.
  final String items;

  @override
  State<BuyPage> createState() => _BuyPageState();
}

final class _BuyPageState extends State<BuyPage> {
  String? _error;
  var _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_start()));
  }

  @override
  void didUpdateWidget(BuyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items == widget.items) return;
    _started = false;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_start()));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watchCartViewModel().value;
    final failed =
        cart.status == CartStatus.failed && cart.operation == CartOperation.buy;
    return CheckoutScaffold(
      body: Center(
        child: failed || _error != null
            ? _BuyFailure(
                message: _error ?? cart.message ?? 'Unable to open checkout.',
                onRetry: () {
                  _started = false;
                  _error = null;
                  unawaited(_start());
                },
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _start() async {
    if (_started || !mounted) return;
    _started = true;
    final items = parseBuyItems(widget.items);
    if (items == null) {
      _fail('Malformed checkout link.');
      return;
    }
    final shell = context.readStoreShellViewModel().state;
    final country = Uri.parse(
      RouterController.of<CommerceRoute>(context).currentRoute.location,
    ).queryParameters['context/address_country'];
    final region = country == null
        ? shell.selectedRegion
        : shell.regionForCountry(country);
    final regionAvailable = region.match(
      some: (_) => true,
      none: () => false,
    );
    if (country != null && !regionAvailable) {
      _fail('This store does not ship to the requested country.');
      return;
    }
    await context.readCartViewModel().restore();
    if (!mounted) return;
    final ok = await context.readCartViewModel().buy(BuyCartBody(
          items: items,
          regionId: region.match(
            some: (value) => value.id,
            none: () => null,
          ),
        ));
    if (!mounted) return;
    if (ok) {
      context.pushCheckoutStep('address');
    } else {
      setState(() {});
    }
  }

  void _fail(String message) {
    if (mounted) setState(() => _error = message);
  }
}

final class _BuyFailure extends StatelessWidget {
  const _BuyFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
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
