import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_customer_group_api.g.dart';

/// Generated customer-group API isolated from Store and customer contracts.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminCustomerGroupApi {
  /// Binds the group client to Dio-managed authorization.
  factory AdminCustomerGroupApi(Dio dio, {String? baseUrl}) =
      _$AdminCustomerGroupApi;

  /// Creates one merchant customer segment.
  @POST('/admin/customer-groups')
  Future<AdminCustomerGroupCreateResponse> createCustomerGroup(
    @Body() AdminCreateCustomerGroup body,
  );

  /// Reads one merchant-visible group and its active customer references.
  @GET('/admin/customer-groups/{id}')
  Future<AdminCustomerGroupDetailResponse> customerGroup(@Path() String id);

  /// Applies one atomic add/remove membership batch.
  @POST('/admin/customer-groups/{id}/customers')
  Future<AdminCustomerGroupDetailResponse> updateCustomerGroupCustomers(
    @Path() String id,
    @Body() AdminBatchCustomerGroupCustomers body,
  );

  /// Lists customers for Medusa's Add Customers focus surface.
  @GET('/admin/customers')
  Future<AdminCustomerList> listCustomerGroupCandidates(
    @Query('q') String query,
    @Query('has_account') String hasAccount,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Retires one customer group and returns the Medusa acknowledgement.
  @DELETE('/admin/customer-groups/{id}')
  Future<AdminCustomerGroupDeleted> deleteCustomerGroup(@Path() String id);

  /// Replaces the merchant-facing name and returns refreshed group detail.
  @POST('/admin/customer-groups/{id}')
  Future<AdminCustomerGroupDetailResponse> updateCustomerGroup(
    @Path() String id,
    @Body() AdminUpdateCustomerGroup body,
  );

  /// Lists customers belonging to one active group.
  @GET('/admin/customers')
  Future<AdminCustomerList> listCustomerGroupCustomers(
    @Query('groups') String groupId,
    @Query('q') String query,
    @Query('has_account') String hasAccount,
    @Query('created_at') String createdAt,
    @Query('updated_at') String updatedAt,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Lists merchant-visible groups through Medusa query parameters.
  @GET('/admin/customer-groups')
  Future<AdminCustomerGroupList> listCustomerGroups(
    @Query('q') String query,
    @Query('created_at') String createdAt,
    @Query('updated_at') String updatedAt,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );
}
