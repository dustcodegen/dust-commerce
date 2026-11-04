import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:flutter/material.dart';

import 'checkout_layout.dart';
import 'checkout_not_found.dart';
import 'checkout_scaffold.dart';

/// Medusa-compatible public checkout prepared by the route-level cart guard.
@AppRoute('/checkout', name: 'checkout', guards: [CheckoutGuard])
final class CheckoutPage extends StatefulWidget {
  /// Creates the checkout route.
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _deliveryLoadScheduled = false;
  bool _paymentLoadScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.readCheckoutViewModel().prepare();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watchCartViewModel().value;
    // Keep an active checkout mounted while a cart mutation is in flight.
    // Replacing it with a spinner disposes the address section before its
    // successful save can advance to Delivery.
    if (cart.status == CartStatus.idle || cart.cart == null) {
      return const CheckoutScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final view = cart.cart;
    if (view == null) {
      return const CheckoutScaffold(body: CheckoutNotFound());
    }
    final checkout = context.watchCheckoutViewModel().value;
    final account = context.watchAccountViewModel().value;
    final addresses = context.watchAddressBookViewModel().value;
    if (account.customer != null &&
        addresses.status == AddressBookStatus.idle) {
      _scheduleAddressLoad();
    }
    if (checkout.status == CheckoutStatus.idle) _schedulePrepare();
    if (checkout.status == CheckoutStatus.idle) {
      return const CheckoutScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final requested = context.checkoutStep;
    final step = _availableStep(requested, cart);
    if (step != requested) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.replaceCheckoutStep(step);
      });
    }
    final deliveryFailed = checkout.status == CheckoutStatus.failed &&
        checkout.operation == CheckoutOperation.delivery;
    if (step == 'delivery' && cart.shippingOptions.isEmpty && !deliveryFailed) {
      _scheduleDeliveryLoad();
    }
    final paymentFailed = checkout.status == CheckoutStatus.failed &&
        checkout.operation == CheckoutOperation.payment;
    if (step == 'payment' &&
        !checkout.paymentProvidersLoaded &&
        !paymentFailed) {
      _schedulePaymentLoad();
    }
    return CheckoutScaffold(
      body: CheckoutLayout(
        step: step,
        checkout: checkout,
        cart: cart,
        customer: account.customer,
        addressBook: addresses,
      ),
    );
  }

  void _schedulePrepare() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readCheckoutViewModel().prepare();
    });
  }

  void _scheduleAddressLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final addresses = context.readAddressBookViewModel();
      if (addresses.state.status == AddressBookStatus.idle) {
        addresses.load();
      }
    });
  }

  void _scheduleDeliveryLoad() {
    if (_deliveryLoadScheduled) return;
    _deliveryLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await context.readCheckoutViewModel().loadDelivery();
      _deliveryLoadScheduled = false;
    });
  }

  void _schedulePaymentLoad() {
    if (_paymentLoadScheduled) return;
    _paymentLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await context.readCheckoutViewModel().loadPaymentMethods();
      _paymentLoadScheduled = false;
    });
  }

  static String _availableStep(
    String requested,
    CartState cart,
  ) {
    // Deep links must follow server state, not a stale local draft.
    final serverCart = cart.cart?.cart;
    if (serverCart?.shippingAddress == null) return 'address';
    if ((requested == 'payment' || requested == 'review') &&
        serverCart?.shippingMethod == null) {
      return 'delivery';
    }
    if (requested == 'review' && serverCart?.paymentSession == null) {
      return 'payment';
    }
    return requested;
  }
}
