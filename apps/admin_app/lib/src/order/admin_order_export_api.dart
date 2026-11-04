import 'package:dust_dart/http.dart';

part 'admin_order_export_api.g.dart';

/// Generated feature client for authenticated order CSV downloads.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'text/csv'},
  target: HttpTarget.flutter,
)
abstract interface class AdminOrderExportApi {
  /// Binds the client to the same intercepted [dio] used by Admin requests.
  factory AdminOrderExportApi(Dio dio, {String? baseUrl}) =
      _$AdminOrderExportApi;

  /// Downloads every order matching the active table query.
  @GET('/admin/orders/export')
  Future<String> exportOrders(
    @Query('q') String query,
    @Query('status') String statuses,
    @Query('region_id') String regionIds,
    @Query('sales_channel_id') String salesChannelIds,
    @Query('created_at') String createdAt,
    @Query('updated_at') String updatedAt,
    @Query('order') String order,
  );
}
