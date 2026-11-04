// ignore_for_file: public_member_api_docs

import 'package:admin_app/src/bootstrap/admin_dependencies.dart';
import 'package:admin_app/src/customer/admin_customer_address_create_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_address_delete_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_create_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_delete_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_detail_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_edit_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_create_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_candidate_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_delete_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_edit_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_membership_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_view_model.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_view_model.dart';
import 'package:admin_app/src/order/admin_fulfillment_context_view_model.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:admin_app/src/order/admin_order_view_model.dart';
import 'package:admin_app/src/order/admin_return_view_model.dart';
import 'package:admin_app/src/product/admin_product_create_view_model.dart';
import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:admin_app/src/product_option/admin_product_option_detail_view_model.dart';
import 'package:admin_app/src/product_option/admin_product_option_view_model.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_view_model.dart';
import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_view_model.dart';
import 'package:admin_app/src/promotion/admin_promotion_view_model.dart';
import 'package:admin_app/src/session/admin_session_view_model.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_view_model.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_view_model.dart';
import 'package:flutter/widgets.dart';

final class AdminViewModelScope extends StatelessWidget {
  const AdminViewModelScope({
    required this.dependencies,
    required this.child,
    super.key,
  });
  final AdminDependencies dependencies;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final deps = dependencies;
    return AdminSessionViewModelScope.value(
      value: deps.session,
      child: AdminCustomerServiceViewModelScope.value(
        value: deps.customerService,
        child: AdminOrderViewModelScope.value(
          value: deps.orders,
          child: AdminCustomerAddressCreateViewModelScope.value(
            value: deps.customers.addressCreate,
            child: AdminCustomerAddressDeleteViewModelScope.value(
              value: deps.customers.addressDelete,
              child: AdminCustomerDetailViewModelScope.value(
                value: deps.customers.detail,
                child: AdminCustomerDeleteViewModelScope.value(
                  value: deps.customers.delete,
                  child: AdminCustomerEditViewModelScope.value(
                    value: deps.customers.edit,
                    child: AdminCustomerCreateViewModelScope.value(
                      value: deps.customers.create,
                      child: AdminCustomerViewModelScope.value(
                        value: deps.customers.list,
                        child: AdminCustomerGroupCandidateViewModelScope.value(
                          value: deps.customerGroups.candidates,
                          child: AdminCustomerGroupCreateViewModelScope.value(
                            value: deps.customerGroups.create,
                            child: AdminCustomerGroupDeleteViewModelScope.value(
                              value: deps.customerGroups.delete,
                              child: AdminCustomerGroupEditViewModelScope.value(
                                value: deps.customerGroups.edit,
                                child:
                                    AdminCustomerGroupMembershipViewModelScope
                                        .value(
                                  value: deps.customerGroups.membership,
                                  child: AdminCustomerGroupDetailViewModelScope
                                      .value(
                                    value: deps.customerGroups.detail,
                                    child:
                                        AdminCustomerGroupViewModelScope.value(
                                      value: deps.customerGroups.list,
                                      child:
                                          AdminOrderDetailViewModelScope.value(
                                        value: deps.orderDetail,
                                        child:
                                            AdminFulfillmentContextViewModelScope
                                                .value(
                                          value: deps.fulfillmentContext,
                                          child:
                                              AdminReturnViewModelScope.value(
                                            value: deps.returns,
                                            child: AdminProductViewModelScope
                                                .value(
                                              value: deps.products,
                                              child:
                                                  AdminProductDetailViewModelScope
                                                      .value(
                                                value: deps.productDetail,
                                                child:
                                                    AdminProductCreateViewModelScope
                                                        .value(
                                                  value: deps.productCreate,
                                                  child:
                                                      AdminProductOptionViewModelScope
                                                          .value(
                                                    value: deps.productOptions,
                                                    child:
                                                        AdminProductOptionDetailViewModelScope
                                                            .value(
                                                      value: deps
                                                          .productOptionDetail,
                                                      child:
                                                          AdminProductTypeViewModelScope
                                                              .value(
                                                        value:
                                                            deps.productTypes,
                                                        child:
                                                            AdminProductTypeDetailViewModelScope
                                                                .value(
                                                          value: deps
                                                              .productTypeDetail,
                                                          child:
                                                              AdminShippingProfileViewModelScope
                                                                  .value(
                                                            value: deps
                                                                .shippingProfiles,
                                                            child:
                                                                AdminShippingProfileDetailViewModelScope
                                                                    .value(
                                                              value: deps
                                                                  .shippingProfileDetail,
                                                              child:
                                                                  AdminPromotionViewModelScope
                                                                      .value(
                                                                value: deps
                                                                    .promotions,
                                                                child:
                                                                    AdminPromotionDetailViewModelScope
                                                                        .value(
                                                                  value: deps
                                                                      .promotionDetail,
                                                                  child: child,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
