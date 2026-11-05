import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_stock_location_api.g.dart';

/// Dedicated Admin client for the Inventory/Locations route.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminStockLocationApi {
  /// Binds location reads to Dio's shared Admin authorization interceptor.
  factory AdminStockLocationApi(Dio dio, {String? baseUrl}) =
      _$AdminStockLocationApi;

  /// Reads one searchable page of active stock locations.
  @GET('/admin/stock-locations')
  Future<AdminStockLocationList> list(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );
}
