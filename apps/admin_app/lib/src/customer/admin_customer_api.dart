import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_customer_api.g.dart';

/// Generated customer API isolated from storefront contracts.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminCustomerApi {
  /// Binds the customer client to Dio-managed authorization.
  factory AdminCustomerApi(Dio dio, {String? baseUrl}) = _$AdminCustomerApi;

  /// Lists merchant-visible customers using Medusa query parameters.
  @GET('/admin/customers')
  Future<AdminCustomerList> listCustomers(
    @Query('q') String query,
    @Query('has_account') String hasAccount,
    @Query('created_at') String createdAt,
    @Query('updated_at') String updatedAt,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Creates one non-authenticating customer profile.
  @POST('/admin/customers')
  Future<AdminCustomerDetail> createCustomer(@Body() AdminCreateCustomer body);

  /// Adds one reusable destination and returns the refreshed customer.
  @POST('/admin/customers/{id}/addresses')
  Future<AdminCustomerDetail> createCustomerAddress(
    @Path() String id,
    @Body() AdminCreateCustomerAddress body,
  );

  /// Removes one owned destination and returns its refreshed parent.
  @DELETE('/admin/customers/{id}/addresses/{address_id}')
  Future<AdminCustomerAddressDeleted> deleteCustomerAddress(
    @Path() String id,
    @Path('address_id') String addressId,
  );

  /// Partially updates one owned destination and returns its refreshed parent.
  @POST('/admin/customers/{id}/addresses/{address_id}')
  Future<AdminCustomerDetail> updateCustomerAddress(
    @Path() String id,
    @Path('address_id') String addressId,
    @Body() AdminUpdateCustomerAddress body,
  );

  /// Reads one merchant-visible customer profile and active address book.
  @GET('/admin/customers/{id}')
  Future<AdminCustomerDetail> customer(@Path() String id);

  /// Replaces the editable contact fields for one customer profile.
  @PATCH('/admin/customers/{id}')
  Future<AdminCustomerDetail> updateCustomer(
    @Path() String id,
    @Body() AdminUpdateCustomer body,
  );

  /// Deletes one customer profile and its exclusive sign-in capability.
  @DELETE('/admin/customers/{id}')
  Future<AdminCustomerDeleted> deleteCustomer(@Path() String id);

  /// Lists only orders owned by one customer for the detail route.
  @GET('/admin/orders')
  Future<AdminOrderList> listCustomerOrders(
    @Query('customer_id') String customerId,
    @Query('q') String query,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );
}
