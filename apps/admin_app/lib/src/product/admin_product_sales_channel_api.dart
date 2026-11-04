import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_product_sales_channel_api.g.dart';

/// Generated product-detail client using the shared Dio authorization pipeline.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminProductSalesChannelApi {
  /// Binds product availability reads to one configured Dio instance.
  factory AdminProductSalesChannelApi(Dio dio, {String? baseUrl}) =
      _$AdminProductSalesChannelApi;

  /// Reads the channels explicitly attached to one product.
  @GET('/admin/products/{id}/sales-channels')
  Future<AdminSalesChannelList> productSalesChannels(@Path() String id);

  /// Atomically replaces every channel attached to one product.
  @PUT('/admin/products/{id}/sales-channels')
  Future<AdminSalesChannelList> updateProductSalesChannels(
    @Path() String id,
    @Body() AdminUpdateProductSalesChannels body,
  );

  /// Reads the total non-deleted channel count used by Medusa's section copy.
  @GET('/admin/sales-channels')
  Future<AdminSalesChannelList> allSalesChannels(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Reads the full rows displayed by the Medusa-shaped assignment editor.
  @GET('/admin/sales-channels')
  Future<AdminSalesChannelDetailList> editorSalesChannels(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );
}
