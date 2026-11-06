import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_promotion_api.g.dart';

/// Generated promotions client using Dio's shared authorization policy.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminPromotionApi {
  /// Binds promotion requests to one configured Dio instance.
  factory AdminPromotionApi(Dio dio, {String? baseUrl}) = _$AdminPromotionApi;

  /// Creates one guarded code-based promotion.
  @POST('/admin/promotions')
  Future<AdminPromotionDetail> createPromotion(
    @Body() AdminCreatePromotion body,
  );

  /// Reads one searchable page of promotions.
  @GET('/admin/promotions')
  Future<AdminPromotionList> list(
    @Query('q') String query,
    @Query('created_at') String createdAt,
    @Query('updated_at') String updatedAt,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Reads one active promotion detail.
  @GET('/admin/promotions/{id}')
  Future<AdminPromotionDetail> promotion(@Path() String id);

  /// Replaces one guarded active promotion.
  @PATCH('/admin/promotions/{id}')
  Future<AdminPromotionDetail> updatePromotion(
    @Path() String id,
    @Body() AdminUpdatePromotion body,
  );

  /// Retires one active promotion.
  @DELETE('/admin/promotions/{id}')
  Future<AdminPromotionDeleted> deletePromotion(@Path() String id);
}
