import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';

part 'order_return_history_api.g.dart';

/// Focused generated client for authenticated customer return history.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class OrderReturnHistoryApi {
  /// Binds return-history calls to the shared Dio authorization pipeline.
  factory OrderReturnHistoryApi(Dio dio, {String? baseUrl}) =
      _$OrderReturnHistoryApi;

  /// Lists one bounded page through the authenticated order-owner boundary.
  @GET('/store/orders/{id}/returns')
  Future<OrderReturnListView> returns(
    @Path() String id, {
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });
}
