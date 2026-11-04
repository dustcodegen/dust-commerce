import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_order_region_api.g.dart';

/// Generated client for the order filter's Admin-only region discovery.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminOrderRegionApi {
  /// Binds the client to the same Dio authorization pipeline as Admin orders.
  factory AdminOrderRegionApi(Dio dio, {String? baseUrl}) =
      _$AdminOrderRegionApi;

  /// Lists active selling-region choices in stable display order.
  @GET('/admin/regions')
  Future<AdminRegionList> listRegions(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );
}
