import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_product_shipping_profile_api.g.dart';

/// Generated product shipping client using Dio's shared authorization policy.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminProductShippingProfileApi {
  /// Binds profile reads and writes to one configured Dio instance.
  factory AdminProductShippingProfileApi(Dio dio, {String? baseUrl}) =
      _$AdminProductShippingProfileApi;

  /// Reads a searchable page of active fulfillment profiles.
  @GET('/admin/shipping-profiles')
  Future<AdminShippingProfileList> shippingProfiles(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Atomically replaces or clears one product's scalar profile.
  @PATCH('/admin/products/{id}/shipping-profile')
  Future<AdminProductShippingProfile> updateProductShippingProfile(
    @Path() String id,
    @Body() AdminUpdateProductShippingProfile body,
  );
}
