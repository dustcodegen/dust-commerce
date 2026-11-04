import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_shipping_profile_api.g.dart';

/// Generated settings client using Dio's shared authorization policy.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminShippingProfileApi {
  /// Binds profile settings requests to one configured Dio instance.
  factory AdminShippingProfileApi(Dio dio, {String? baseUrl}) =
      _$AdminShippingProfileApi;

  /// Reads one searchable page of active fulfillment profiles.
  @GET('/admin/shipping-profiles')
  Future<AdminShippingProfileList> list(
    @Query('q') String query,
    @Query('name') String name,
    @Query('type') String type,
    @Query('created_at') String createdAt,
    @Query('updated_at') String updatedAt,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Creates one fulfillment requirement group.
  @POST('/admin/shipping-profiles')
  Future<AdminShippingProfile> create(
    @Body() AdminCreateShippingProfile body,
  );

  /// Reads one active fulfillment profile.
  @GET('/admin/shipping-profiles/{id}')
  Future<AdminShippingProfile> find(@Path() String id);

  /// Soft-deletes one fulfillment profile.
  @DELETE('/admin/shipping-profiles/{id}')
  Future<void> delete(@Path() String id);
}
