import 'package:admin_app/src/customer/admin_customer_address_create_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_address_delete_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_create_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_delete_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_detail_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_edit_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_view_model.dart';
import 'package:dio/dio.dart';

/// Customer API and ViewModels sharing one authenticated Dio client.
final class AdminCustomerDependencies {
  /// Creates the customer feature graph.
  factory AdminCustomerDependencies(Dio dio, String baseUrl) {
    final api = AdminCustomerApi(dio, baseUrl: baseUrl);
    return AdminCustomerDependencies._(
      addressCreate: AdminCustomerAddressCreateViewModel(
        AdminCustomerAddressCreateViewModelArgs(api: api),
      ),
      addressDelete: AdminCustomerAddressDeleteViewModel(
        AdminCustomerAddressDeleteViewModelArgs(api: api),
      ),
      list: AdminCustomerViewModel(AdminCustomerViewModelArgs(api: api)),
      create: AdminCustomerCreateViewModel(
        AdminCustomerCreateViewModelArgs(api: api),
      ),
      detail: AdminCustomerDetailViewModel(
        AdminCustomerDetailViewModelArgs(api: api),
      ),
      delete: AdminCustomerDeleteViewModel(
        AdminCustomerDeleteViewModelArgs(api: api),
      ),
      edit: AdminCustomerEditViewModel(
        AdminCustomerEditViewModelArgs(api: api),
      ),
    );
  }

  const AdminCustomerDependencies._({
    required this.addressCreate,
    required this.addressDelete,
    required this.list,
    required this.create,
    required this.detail,
    required this.delete,
    required this.edit,
  });

  /// Customer-address creation command state.
  final AdminCustomerAddressCreateViewModel addressCreate;

  /// Customer-address deletion command state.
  final AdminCustomerAddressDeleteViewModel addressDelete;

  /// Customer collection state.
  final AdminCustomerViewModel list;

  /// Customer-creation command state.
  final AdminCustomerCreateViewModel create;

  /// Selected customer detail state.
  final AdminCustomerDetailViewModel detail;

  /// Customer-deletion command state.
  final AdminCustomerDeleteViewModel delete;

  /// Customer-edit command state.
  final AdminCustomerEditViewModel edit;
}
