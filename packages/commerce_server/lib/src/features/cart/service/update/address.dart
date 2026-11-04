import 'package:commerce_server/src/features/cart/model/cart.dart';
import 'package:commerce_server/src/features/cart/repository/repository.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Why checkout destinations could not be retained on a cart.
enum CartAddressFailure {
  /// The cart is missing or no longer active.
  noCart,

  /// At least one destination is outside the cart selling region.
  countryNotInRegion,
}

/// Atomically replaces the contact and address step for an active cart.
Future<Result<Option<CartAddressFailure>, SqlxError>> updateCartAddresses(
  CommerceDatabase database, {
  required String cartId,
  required String email,
  required Address shipping,
  required Address? billing,
}) =>
    database.transaction((tx) async {
      final reads = CartReadRepository(tx);
      final addresses = CartAddressRepository(tx);
      final carts = CartUpdateRepository(tx);
      final loaded = await loadCart(reads, cartId);
      if (loaded case Err(:final error)) return Err(error);
      final cartOption = (loaded as Ok<Option<CartResponse>, SqlxError>).value;
      if (cartOption case None()) {
        return const Ok(Some(CartAddressFailure.noCart));
      }
      final cart = (cartOption as Some<CartResponse>).value;
      final accepted = cart.region.countries;
      if (!accepted.contains(shipping.countryCode) ||
          (billing != null && !accepted.contains(billing.countryCode))) {
        return const Ok(Some(CartAddressFailure.countryNotInRegion));
      }

      final emailWrite = await carts.setCartEmail(cartId, email);
      if (emailWrite case Err(:final error)) return Err(error);
      if ((emailWrite as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        return const Ok(Some(CartAddressFailure.noCart));
      }
      final shippingWrite = await _upsert(
        addresses,
        cartId,
        'shipping',
        shipping,
      );
      if (shippingWrite case Err(:final error)) return Err(error);
      if (billing case final value?) {
        final billingWrite = await _upsert(
          addresses,
          cartId,
          'billing',
          value,
        );
        if (billingWrite case Err(:final error)) return Err(error);
      } else {
        final cleared = await addresses.clearBilling(cartId);
        if (cleared case Err(:final error)) return Err(error);
      }
      return const Ok(None<CartAddressFailure>());
    });

Future<Result<ExecResult, SqlxError>> _upsert(
  CartAddressRepository repository,
  String cartId,
  String kind,
  Address address,
) =>
    repository.upsertAddress(
      cartId,
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
