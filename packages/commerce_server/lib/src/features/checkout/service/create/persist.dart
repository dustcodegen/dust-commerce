import 'package:commerce_server/src/features/cart/model/cart.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:commerce_server/src/features/checkout/repository/repository.dart';
import 'package:commerce_server/src/features/checkout/service/create/guest.dart';
import 'package:commerce_server/src/features/checkout/service/create/outcome.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Persists one validated checkout inside the caller-owned transaction.
Future<Result<CheckoutPlacementOutcome, SqlxError>> persistOrder(
  Executor tx, {
  required String cartId,
  required String email,
  required Option<String> customerId,
  required Address shippingAddress,
  required Address billingAddress,
  required DateTime placedAt,
  required String Function() nextId,
}) async {
  final carts = CartReadRepository(tx);
  final orders = CheckoutCreateRepository(tx);
  final reads = CheckoutReadRepository(tx);
  final loaded = await loadCart(carts, cartId);
  if (loaded case Err(:final error)) return Err(error);

  final cartOption = (loaded as Ok<Option<CartResponse>, SqlxError>).value;
  if (cartOption case None()) return const Ok(checkoutNoCart);
  final cart = (cartOption as Some<CartResponse>).value;
  if (cart.customerId case final owner? when customerId != Some(owner)) {
    return const Ok(checkoutWrongCustomer);
  }
  if (!cart.region.countries.contains(shippingAddress.countryCode) ||
      !cart.region.countries.contains(billingAddress.countryCode)) {
    return const Ok(checkoutCountryNotInRegion);
  }

  final previousId = await reads.orderIdForCart(cartId);
  if (previousId case Err(:final error)) return Err(error);
  final previous = optionOf((previousId as Ok<String?, SqlxError>).value);
  if (previous case Some(value: final orderId)) {
    final response = await reads.findOrder(orderId);
    if (response case Err(:final error)) return Err(error);
    final order = optionOf((response as Ok<OrderResponse?, SqlxError>).value);
    if (order case Some(value: final existing)) {
      return Ok(CheckoutPlacementReady(existing));
    }
    return Err(SqlxError.decode('Existing cart order could not be read'));
  }
  if (cart.isEmpty) return const Ok(checkoutEmptyCart);
  final shippingMethod = cart.shippingMethod;
  if (shippingMethod == null) return const Ok(checkoutShippingNotSelected);
  if (cart.paymentSession?.providerId != 'manual') {
    return const Ok(checkoutPaymentNotSelected);
  }
  final providerEnabled = await carts.hasEnabledPaymentProvider(cartId);
  if (providerEnabled case Err(:final error)) return Err(error);
  if ((providerEnabled as Ok<int, SqlxError>).value == 0) {
    return const Ok(checkoutPaymentNotSelected);
  }

  for (final line in cart.items) {
    final taken = await orders.reserveStock(line.variantId, line.quantity);
    if (taken case Err(:final error)) return Err(error);
    if ((taken as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
      return const Ok(checkoutOutOfStock);
    }
  }

  if (customerId case None()) {
    final guest = await persistGuestCustomer(
      orders,
      nextId,
      email,
      shippingAddress,
    );
    if (guest case Err(:final error)) return Err(error);
  }

  final orderId = nextId();
  final promotion = cart.promotions.firstOrNull;
  final written = await orders.insertOrder(
    orderId,
    cartId,
    cart.region.id,
    customerId.match<String?>(
      some: (value) => value,
      none: () => cart.customerId,
    ),
    email,
    cart.region.currencyCode,
    cart.subtotal.amount,
    cart.shippingTotal.amount,
    cart.discountTotal.amount,
    cart.tax.amount,
    cart.total.amount,
    shippingMethod.optionId,
    shippingMethod.name,
    promotion?.code,
    placedAt.toUtc().toIso8601String(),
  );
  if (written case Err(:final error)) return Err(error);

  final channel = await orders.snapshotSalesChannel(orderId, cartId);
  if (channel case Err(:final error)) return Err(error);

  for (final line in cart.items) {
    final copied = await orders.insertOrderItem(
      nextId(),
      orderId,
      line.variantId,
      line.productId,
      line.productHandle,
      line.thumbnail,
      line.title,
      line.variantTitle,
      line.unitPrice.amount,
      line.unitPrice.currencyCode,
      line.quantity,
    );
    if (copied case Err(:final error)) return Err(error);
  }

  for (final (kind, address) in [
    ('shipping', shippingAddress),
    ('billing', billingAddress),
  ]) {
    final recorded = await orders.insertOrderAddress(
      orderId,
      kind,
      address.firstName,
      address.lastName,
      address.company,
      address.line1,
      address.line2,
      address.city,
      address.province,
      address.postalCode,
      address.countryCode,
      address.phone,
    );
    if (recorded case Err(:final error)) return Err(error);
  }

  if (!cart.discountTotal.isZero && promotion != null) {
    final counted = await orders.countRedemption(promotion.id);
    if (counted case Err(:final error)) return Err(error);
  }

  final completed = await orders.completeCart(
    cartId,
    placedAt.toUtc().toIso8601String(),
  );
  if (completed case Err(:final error)) return Err(error);
  final emptied = await orders.clearCart(cartId);
  if (emptied case Err(:final error)) return Err(error);
  final response = await reads.findOrder(orderId);
  if (response case Err(:final error)) return Err(error);
  final created = optionOf((response as Ok<OrderResponse?, SqlxError>).value);
  return switch (created) {
    Some(value: final order) => Ok(CheckoutPlacementReady(order)),
    None() => Err(
        SqlxError.decode('The order was written but could not be read back'),
      ),
  };
}
