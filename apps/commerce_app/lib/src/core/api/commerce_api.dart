import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';

part 'commerce_api.g.dart';

/// Generated Store API sharing wire models with the server.
///
/// The factory overrides the development base URL per environment.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class CommerceApi {
  /// Binds the client to [dio], optionally against another [baseUrl].
  factory CommerceApi(Dio dio, {String? baseUrl}) = _$CommerceApi;

  /// Registers a customer account.
  @POST('/store/customers')
  Future<CustomerRegistrationView> registerAccount(
    @Body() RegisterAccountBody body,
  );

  /// Consumes one single-use email verification capability.
  @POST('/auth/customer/emailpass/verification/confirm')
  Future<EmailVerified> confirmEmail(@Body() VerifyEmailBody body);

  /// Exchanges email/password credentials for a bearer token.
  @POST('/auth/customer/emailpass')
  Future<IssuedToken> signIn(@Body() Credentials body);

  /// Reads the customer proven by the bearer configured on the Dio client.
  @GET('/store/customers/me')
  Future<Customer> currentCustomer();

  /// Replaces editable fields on the authenticated customer profile.
  @PATCH('/store/customers/me')
  Future<Customer> updateCustomerProfile(
    @Body() UpdateCustomerProfileBody body,
  );

  /// Rotates the password and revokes every session for this customer.
  @PATCH('/store/customers/me/password')
  Future<PasswordChanged> changePassword(@Body() ChangePasswordBody body);

  /// Lists the authenticated customer's active saved addresses.
  @GET('/store/customers/me/addresses')
  Future<CustomerAddressListView> customerAddresses();

  /// Adds one reusable address to the authenticated customer.
  @POST('/store/customers/me/addresses')
  Future<CustomerAddressView> createCustomerAddress(
    @Body() CustomerAddressInput body,
  );

  /// Replaces one reusable address owned by the authenticated customer.
  @PATCH('/store/customers/me/addresses/{id}')
  Future<CustomerAddressView> updateCustomerAddress(
    @Path() String id,
    @Body() CustomerAddressInput body,
  );

  /// Soft-deletes one reusable address owned by the authenticated customer.
  @DELETE('/store/customers/me/addresses/{id}')
  Future<CustomerAddressDeleted> deleteCustomerAddress(@Path() String id);

  /// Lists active selling regions for account country selectors.
  @GET('/store/regions')
  Future<SellingRegionListView> regions();

  /// Payment providers enabled for one selling region.
  @GET('/store/payment-providers')
  Future<PaymentProviderListView> paymentProviders(
    @Query('region_id') String regionId,
  );

  /// Revokes the bearer token configured on the Dio client.
  @DELETE('/auth/session')
  Future<SessionDeleted> signOut();

  /// Persists one guest-compatible customer-service request.
  @POST('/store/customer-service')
  Future<CustomerServiceSubmission> submitCustomerService(
    @Body() CustomerServiceRequestBody body,
  );

  /// A page of the published catalogue.
  @GET('/store/products')
  Future<ProductPageView> products({
    @Query('currency') String? currency,
    @Query('q') String? query,
    @Query('sortBy') String? sortBy,
    @Query('collection') String? collection,
    @Query('category') List<String> categoryHandles = const [],
    @Query('labels') List<String> labels = const [],
    @Query('tag') String? tag,
    @Query('minPrice') int? minPrice,
    @Query('maxPrice') int? maxPrice,
    @Query('onSale') String? onSale,
    @Query('optionValueIds') List<String> optionValueIds = const [],
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  /// Active stable option values used by the store refinement sidebar.
  @GET('/store/product-options')
  Future<ProductOptionFilterListView> productOptions({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  /// Public collections used by featured rails and collection routes.
  @GET('/store/collections')
  Future<ProductCollectionListView> collections({
    @Query('handle') String? handle,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  /// Public active category nodes used by nested category routes.
  @GET('/store/product-categories')
  Future<ProductCategoryListView> categories({
    @Query('handle') String? handle,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  /// One product by the handle the storefront routes on.
  @GET('/store/products/{handle}')
  Future<Product> product(
    @Path() String handle, {
    @Query('currency') String? currency,
  });

  /// Starts an empty cart in the selected selling region.
  @POST('/store/carts')
  Future<CartView> createCart(@Body() CreateCartBody body);

  /// Creates a cart and all permalink lines atomically.
  @POST('/store/carts/buy')
  Future<CartView> createCartWithItems(@Body() BuyCartBody body);

  /// One cart with the totals the server computed.
  @GET('/store/carts/{id}')
  Future<CartView> cart(@Path() String id);

  /// Reprices an active cart under another selling region.
  @PATCH('/store/carts/{id}')
  Future<CartView> updateCartRegion(
    @Path() String id,
    @Body() UpdateCartRegionBody body,
  );

  /// Retains the validated checkout contact and destinations on the cart.
  @PUT('/store/carts/{id}/addresses')
  Future<CartView> updateCartAddresses(
    @Path() String id,
    @Body() UpdateCartAddressesBody body,
  );

  /// Claims the current guest cart for the authenticated customer.
  @POST('/store/carts/{id}/transfer')
  Future<CartView> transferCart(@Path() String id);

  /// Adds a variant to a cart, answering with the cart it produced.
  @POST('/store/carts/{id}/line-items')
  Future<CartView> addLine(
    @Path() String id,
    @Body() AddLineBody body,
  );

  /// Replaces one line's quantity after the server rechecks stock.
  @PATCH('/store/carts/{id}/line-items/{lineId}')
  Future<CartView> updateLine(
    @Path() String id,
    @Path() String lineId,
    @Body() UpdateLineBody body,
  );

  /// Removes one line and returns the server's new totals.
  @DELETE('/store/carts/{id}/line-items/{lineId}')
  Future<CartView> removeLine(
    @Path() String id,
    @Path() String lineId,
  );

  /// Delivery choices currently available to a cart.
  @GET('/store/carts/{id}/shipping-options')
  Future<ShippingOptionsView> shippingOptions(@Path() String id);

  /// Selects one delivery choice and returns authoritative totals.
  @POST('/store/carts/{id}/shipping-method')
  Future<CartView> chooseShipping(
    @Path() String id,
    @Body() ChooseShippingBody body,
  );

  /// Retains the payment provider selected for this cart.
  @POST('/store/carts/{id}/payment-sessions')
  Future<CartView> choosePayment(
    @Path() String id,
    @Body() ChoosePaymentBody body,
  );

  /// Applies one promotion code and returns authoritative totals.
  @POST('/store/carts/{id}/promotions')
  Future<CartView> applyPromotion(
    @Path() String id,
    @Body() ApplyPromotionBody body,
  );

  /// Removes the cart's promotion and returns authoritative totals.
  @DELETE('/store/carts/{id}/promotions')
  Future<CartView> removePromotion(@Path() String id);

  /// Turns a cart into an order.
  @POST('/store/checkout')
  Future<Order> checkout(@Body() CheckoutRequest body);

  /// Starts the server-owned manual payment for an order.
  @POST('/store/orders/{id}/payments')
  Future<Order> authorizePayment(
    @Path() String id, {
    @Query('email') String? guestEmail,
  });

  /// Captures an authorized manual payment exactly once.
  @POST('/store/orders/{id}/payments/capture')
  Future<Order> capturePayment(
    @Path() String id, {
    @Query('email') String? guestEmail,
  });

  /// Requests ownership of an order for the authenticated customer.
  @POST('/store/orders/{id}/transfer/request')
  Future<OrderTransferView> requestOrderTransfer(@Path() String id);

  /// Accepts an order transfer using the capability delivered by email.
  @POST('/store/orders/{id}/transfer/accept')
  Future<OrderTransferView> acceptOrderTransfer(
    @Path() String id,
    @Body() OrderTransferDecisionBody body,
  );

  /// Declines an order transfer using the capability delivered by email.
  @POST('/store/orders/{id}/transfer/decline')
  Future<OrderTransferView> declineOrderTransfer(
    @Path() String id,
    @Body() OrderTransferDecisionBody body,
  );

  /// The authenticated customer's orders.
  @GET('/store/orders')
  Future<OrderListView> orders();

  /// One order owned by the authenticated customer.
  @GET('/store/orders/{id}')
  Future<Order> order(@Path() String id);

  /// Active merchant-controlled reasons available to return items.
  @GET('/store/return-reasons')
  Future<ReturnReasonListView> returnReasons({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  /// Requests return processing for items from an authenticated owned order.
  @POST('/store/returns')
  Future<OrderReturnView> requestOrderReturn(
    @Body() OrderReturnRequestBody body,
  );
}
