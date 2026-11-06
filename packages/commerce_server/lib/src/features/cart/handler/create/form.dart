import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/create/buy.dart';
import 'package:commerce_server/src/features/cart/service/update/line.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const FormExtractable _form = FormExtractable();

/// `POST /store/cart/add` — form-compatible add-to-cart boundary.
///
/// This handles the backend request from Medusa's no-JavaScript product form. A
/// missing `cart_id` creates a cart and its first line atomically; an existing
/// capability is checked with the same ownership guard as the JSON route.
Future<Result<CartViewResponse, Rejection>> addFormLineHandler(
  Request request,
) async {
  final decoded = await _form.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final fields = (decoded as Ok<FormMap, Rejection>).value;

  final variant = fields.field<String>('variant_id');
  if (variant case Err(:final error)) return Err(error);
  final quantity = fields.field<int?>('quantity');
  if (quantity case Err(:final error)) return Err(error);
  final cart = fields.field<String?>('cart_id');
  if (cart case Err(:final error)) return Err(error);
  final region = fields.field<String?>('region_id');
  if (region case Err(:final error)) return Err(error);

  final variantId = (variant as Ok<String, Rejection>).value;
  final requestedQuantity = (quantity as Ok<int?, Rejection>).value ?? 1;
  if (requestedQuantity < 1 || requestedQuantity > 100) {
    return const Err(Rejection.unprocessable({
      'quantity': ['Order 1 to 100'],
    }));
  }
  final cartId = _optionalField((cart as Ok<String?, Rejection>).value);
  final regionId = _optionalField((region as Ok<String?, Rejection>).value);

  final context = await request.extract(const Extension<CustomerContext>());
  final customer = context.authenticated;

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;

  if (cartId != null) {
    final access = await cartAccessFor(request, cartId);
    if (access case Err(:final error)) return Err(error);
    final added = await addLine(
      deps.database,
      cartId: cartId,
      variantId: variantId,
      quantity: requestedQuantity,
      nextId: deps.clock.nextId,
    );
    return switch (added) {
      Err() => const Err(Rejection.internal()),
      Ok(value: None()) => cartViewOf(deps.reads, cartId),
      Ok(value: Some(value: AddLineFailure.noCart)) =>
        Err(Rejection.notFound('Cart "$cartId"')),
      Ok(value: Some(value: AddLineFailure.noVariant)) => Err(
          Rejection.status(
            422,
            'Variant "$variantId" is not on sale in this currency',
          ),
        ),
      Ok(value: Some(value: AddLineFailure.outOfStock)) => Err(
          Rejection.conflict('Not enough stock for "$variantId"'),
        ),
    };
  }

  final result = await buyCart(
    deps.database,
    id: deps.clock.nextId(),
    items: [
      AddLineBody(variantId: variantId, quantity: requestedQuantity),
    ],
    regionId: regionId,
    customerId: customer.match(
      some: (value) => value.customer.id,
      none: () => null,
    ),
    email: customer.match(
      some: (value) => value.customer.email,
      none: () => null,
    ),
    nextId: deps.clock.nextId,
  );

  return switch (result) {
    Err() => const Err(Rejection.internal()),
    Ok(value: BuyCartReady(:final cartId)) => cartViewOf(deps.reads, cartId),
    Ok(value: BuyCartRejected(:final failure, :final variantId)) =>
      Err(_rejectionFor(failure, variantId)),
  };
}

String? _optionalField(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

Rejection _rejectionFor(BuyCartFailure failure, String? variantId) =>
    switch (failure) {
      BuyCartFailure.noRegion =>
        Rejection.status(422, 'The requested selling region is unavailable'),
      BuyCartFailure.noVariant => Rejection.status(
          422,
          'Variant "$variantId" is not on sale in this currency',
        ),
      BuyCartFailure.outOfStock =>
        Rejection.conflict('Not enough stock for "$variantId"'),
    };
