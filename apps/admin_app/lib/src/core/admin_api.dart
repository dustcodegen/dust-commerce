import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/http.dart';

part 'admin_api.g.dart';

/// Generated client containing only merchant-admin operations.
@HttpClient(
  baseUrl: 'http://localhost:3878',
  headers: {'accept': 'application/json'},
  target: HttpTarget.flutter,
)
abstract interface class AdminApi {
  /// Binds the client to [dio].
  factory AdminApi(Dio dio, {String? baseUrl}) = _$AdminApi;

  /// Exchanges admin credentials for a bearer token.
  @POST('/auth/admin/emailpass')
  Future<AdminIssuedToken> signIn(@Body() AdminCredentials body);

  /// Reads the admin proven by Dio-managed authorization.
  @GET('/admin/users/me')
  Future<AdminUser> currentUser();

  /// Lists merchant-visible orders with server-owned paging and filtering.
  @GET('/admin/orders')
  Future<AdminOrderList> listOrders(
    @Query('q') String query,
    @Query('status') String statuses,
    @Query('region_id') String regionIds,
    @Query('sales_channel_id') String salesChannelIds,
    @Query('created_at') String createdAt,
    @Query('updated_at') String updatedAt,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Lists merchant-visible products with server-owned paging and search.
  @GET('/admin/products')
  Future<AdminProductList> listProducts(
    @Query('q') String query,
    @Query('status') String statuses,
    @Query('tag_id') String tagIds,
    @Query('type_id') String typeIds,
    @Query('created_at') String createdAt,
    @Query('updated_at') String updatedAt,
    @Query('order') String order,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Downloads every product matching the active Admin table query.
  @GET('/admin/products/export')
  Future<String> exportProducts(
    @Query('q') String query,
    @Query('status') String statuses,
    @Query('tag_id') String tagIds,
    @Query('type_id') String typeIds,
    @Query('created_at') String createdAt,
    @Query('updated_at') String updatedAt,
    @Query('order') String order,
  );

  /// Validates and stages one Medusa product CSV without catalogue mutation.
  @POST('/admin/products/import')
  @MultiPart()
  Future<AdminProductImportPreview> previewProductImport(
    @Part('file') MultipartFile file,
  );

  /// Atomically consumes one staged product import.
  @POST('/admin/products/import/{transactionId}/confirm')
  Future<void> confirmProductImport(@Path() String transactionId);

  /// Lists normalized product types for filters and product selectors.
  @GET('/admin/product-types')
  Future<AdminProductTypeList> listProductTypes(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Creates one reusable product classification.
  @POST('/admin/product-types')
  Future<AdminProductType> createProductType(
    @Body() AdminCreateProductType body,
  );

  /// Reads one reusable product classification.
  @GET('/admin/product-types/{id}')
  Future<AdminProductType> productType(@Path() String id);

  /// Replaces one product classification's merchant-facing value.
  @PATCH('/admin/product-types/{id}')
  Future<AdminProductType> updateProductType(
    @Path() String id,
    @Body() AdminUpdateProductType body,
  );

  /// Soft-deletes one reusable product classification.
  @DELETE('/admin/product-types/{id}')
  Future<void> deleteProductType(@Path() String id);

  /// Lists public product tags for filters and product selectors.
  @GET('/admin/product-tags')
  Future<AdminProductTagList> listProductTags(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Lists globally reusable product options with paging and search.
  @GET('/admin/product-options')
  Future<AdminProductOptionList> listProductOptions(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  /// Creates one globally reusable product option.
  @POST('/admin/product-options')
  Future<AdminProductOptionDetail> createProductOption(
    @Body() AdminCreateProductOption body,
  );

  /// Reads one complete global or exclusive product option.
  @GET('/admin/product-options/{id}')
  Future<AdminProductOptionDetail> productOption(@Path() String id);

  /// Replaces one product option's title, values, and display order.
  @PATCH('/admin/product-options/{id}')
  Future<AdminProductOptionDetail> updateProductOption(
    @Path() String id,
    @Body() AdminUpdateProductOption body,
  );

  /// Soft-deletes one unused product option and its values.
  @DELETE('/admin/product-options/{id}')
  Future<void> deleteProductOption(@Path() String id);

  /// Loads active storefront currencies required by the creation grid.
  @GET('/admin/products/create-context')
  Future<AdminProductCreateContext> productCreateContext();

  /// Creates one complete product, option, variant, inventory, and price graph.
  @POST('/admin/products')
  Future<AdminProductDetail> createProduct(@Body() AdminCreateProduct body);

  /// Streams selected image files before they are attached to a product.
  @POST('/admin/uploads')
  @MultiPart()
  Future<AdminUploadedFileList> uploadMedia(
    @Part('files') List<MultipartFile> files,
  );

  /// Discards one staged upload that is not attached to a product.
  @DELETE('/admin/uploads/{id}')
  Future<void> deleteUpload(@Path() String id);

  /// Reads one complete merchant product detail.
  @GET('/admin/products/{id}')
  Future<AdminProductDetail> product(@Path() String id);

  /// Replaces supported general fields and returns refreshed detail.
  @PATCH('/admin/products/{id}')
  Future<AdminProductDetail> updateProduct(
    @Path() String id,
    @Body() AdminUpdateProduct body,
  );

  /// Replaces only the reusable classification assigned to one product.
  @PATCH('/admin/products/{id}/organization')
  Future<AdminProductDetail> updateProductOrganization(
    @Path() String id,
    @Body() AdminUpdateProductOrganization body,
  );

  /// Soft-deletes one active product and returns a typed acknowledgement.
  @DELETE('/admin/products/{id}')
  Future<AdminProductDeleted> deleteProduct(@Path() String id);

  /// Replaces one variant's Medusa detail-drawer fields.
  @PATCH('/admin/products/{id}/variants/{variantId}')
  Future<AdminProductDetail> updateProductVariant(
    @Path() String id,
    @Path() String variantId,
    @Body() AdminUpdateProductVariant body,
  );

  /// Replaces every active-currency price for one variant.
  @PUT('/admin/products/{id}/variants/{variantId}/prices')
  Future<AdminProductDetail> updateProductVariantPrices(
    @Path() String id,
    @Path() String variantId,
    @Body() AdminUpdateVariantPrices body,
  );

  /// Replaces aggregate stock for selected variants as one transaction.
  @PUT('/admin/products/{id}/stock')
  Future<AdminProductDetail> updateProductStock(
    @Path() String id,
    @Body() AdminUpdateProductStock body,
  );

  /// Replaces product image membership, order, and thumbnail atomically.
  @PUT('/admin/products/{id}/media')
  Future<AdminProductDetail> updateProductMedia(
    @Path() String id,
    @Body() AdminUpdateProductMedia body,
  );

  /// Adds and removes variant associations for one product image.
  @POST('/admin/products/{id}/images/{imageId}/variants/batch')
  Future<AdminBatchImageVariantsResult> batchImageVariants(
    @Path() String id,
    @Path() String imageId,
    @Body() AdminBatchImageVariants body,
  );

  /// Revokes the Dio-managed bearer.
  @DELETE('/auth/admin/session')
  Future<AdminSessionDeleted> signOut();
}
