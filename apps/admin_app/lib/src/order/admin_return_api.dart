import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_return_api.g.dart';

/// Generated client for the protected Admin return boundary.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminReturnApi {
  /// Binds return requests to the Dio instance that owns authorization.
  factory AdminReturnApi(Dio dio, {String? baseUrl}) = _$AdminReturnApi;

  /// Lists returns using Medusa's order-detail query boundary.
  @GET('/admin/returns')
  Future<AdminReturnList> list(
    @Query('order_id') String orderId,
    @Query('status') String statuses,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Atomically records intact and damaged units received for one return.
  @POST('/admin/returns/{id}/receive')
  Future<AdminReturn> receive(
    @Path() String id,
    @Body() AdminReceiveReturn body,
  );
}
