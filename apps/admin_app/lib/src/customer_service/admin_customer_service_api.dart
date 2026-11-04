import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_customer_service_api.g.dart';

/// Generated Admin-only customer-service client.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminCustomerServiceApi {
  /// Binds the support client to the authenticated Admin [dio].
  factory AdminCustomerServiceApi(Dio dio, {String? baseUrl}) =
      _$AdminCustomerServiceApi;

  /// Lists one protected support inbox page.
  @GET('/admin/customer-service')
  Future<AdminCustomerServiceList> list(
    @Query('q') String query,
    @Query('status') String statuses,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Replaces the merchant-owned lifecycle of one request.
  @POST('/admin/customer-service/{id}')
  Future<AdminCustomerServiceRequest> update(
    @Path() String id,
    @Body() AdminUpdateCustomerService body,
  );
}
