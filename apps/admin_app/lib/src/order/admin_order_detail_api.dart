import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_order_detail_api.g.dart';

/// Generated client for the protected Admin order-detail boundary.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminOrderDetailApi {
  /// Binds the client to the Dio instance that owns authorization.
  factory AdminOrderDetailApi(Dio dio, {String? baseUrl}) =
      _$AdminOrderDetailApi;

  /// Reads one complete merchant-visible order snapshot.
  @GET('/admin/orders/{id}')
  Future<AdminOrderDetail> order(@Path() String id);

  /// Lists active merchant reasons used by the refund drawer.
  @GET('/admin/refund-reasons')
  Future<AdminRefundReasonList> refundReasons(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Refunds one captured payment and returns its refreshed audit response.
  @POST('/admin/payments/{id}/refund')
  Future<AdminRefundedPayment> refundPayment(
    @Path() String id,
    @Body() AdminRefundPayment body,
  );

  /// Archives one completed or canceled order and returns its refreshed detail.
  @POST('/admin/orders/{id}/archive')
  Future<AdminOrderDetail> archiveOrder(@Path() String id);

  /// Cancels one eligible order and returns the refreshed merchant snapshot.
  @POST('/admin/orders/{id}/cancel')
  Future<AdminOrderDetail> cancelOrder(@Path() String id);

  /// Completes one non-canceled order and returns the refreshed snapshot.
  @POST('/admin/orders/{id}/complete')
  Future<AdminOrderDetail> completeOrder(@Path() String id);

  /// Lists active stock locations for the fulfillment form.
  @GET('/admin/stock-locations')
  Future<AdminStockLocationList> stockLocations(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Lists methods compatible with one location and the order region.
  @GET('/admin/shipping-options')
  Future<AdminFulfillmentShippingOptionList> fulfillmentShippingOptions(
    @Query('stock_location_id') String stockLocationId,
    @Query('region_id') String regionId,
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Creates one fulfillment and returns the refreshed merchant order.
  @POST('/admin/orders/{id}/fulfillments')
  Future<AdminOrderDetail> createFulfillment(
    @Path() String id,
    @Body() AdminCreateFulfillment body,
  );

  /// Marks one pending fulfillment shipped with optional carrier labels.
  @POST('/admin/orders/{id}/fulfillments/{fulfillment_id}/shipments')
  Future<AdminOrderDetail> createShipment(
    @Path() String id,
    @Path('fulfillment_id') String fulfillmentId,
    @Body() AdminCreateShipment body,
  );

  /// Marks one active fulfillment delivered and returns the refreshed order.
  @POST('/admin/orders/{id}/fulfillments/{fulfillment_id}/mark-as-delivered')
  Future<AdminOrderDetail> markDelivered(
    @Path() String id,
    @Path('fulfillment_id') String fulfillmentId,
    @Body() AdminMarkFulfillmentDelivered body,
  );

  /// Cancels one pending fulfillment and returns the refreshed order.
  @POST('/admin/orders/{id}/fulfillments/{fulfillment_id}/cancel')
  Future<AdminOrderDetail> cancelFulfillment(
    @Path() String id,
    @Path('fulfillment_id') String fulfillmentId,
    @Body() AdminCancelFulfillment body,
  );
}
