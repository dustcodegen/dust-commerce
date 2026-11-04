import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_order_sales_channel_api.g.dart';

/// Generated client for the order filter's Admin-only channel discovery.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminOrderSalesChannelApi {
  /// Binds the client to the shared Dio authorization pipeline.
  factory AdminOrderSalesChannelApi(Dio dio, {String? baseUrl}) =
      _$AdminOrderSalesChannelApi;

  /// Lists non-deleted sales-channel choices in stable display order.
  @GET('/admin/sales-channels')
  Future<AdminSalesChannelList> listSalesChannels(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );
}
