import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/customer_service/model/customer_service_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'customer_service_view_model.g.dart';

/// Dependencies for the guest-compatible support form.
final class CustomerServiceViewModelArgs extends ViewModelArgs {
  /// Creates support dependencies.
  const CustomerServiceViewModelArgs({required this.api, super.observer});

  /// Generated Store API with Dio-owned authorization.
  final CommerceApi api;
}

/// Submits bounded support input and retains only its acknowledgement.
@ViewModel(state: CustomerServiceState, args: CustomerServiceViewModelArgs)
final class CustomerServiceViewModel extends $CustomerServiceViewModel {
  /// Creates the support state machine.
  CustomerServiceViewModel(super.args);

  var _generation = 0;

  /// Clears prior feedback and ignores an older in-flight result.
  void reset() {
    _generation++;
    emit(const CustomerServiceState());
  }

  /// Sends one validated request through the generated client.
  Future<void> submit(CustomerServiceRequestBody input) async {
    if (state.isBusy) return;
    if (!input.validate().isValid) {
      emit(const CustomerServiceState(
        status: CustomerServiceStatus.failed,
        failure: Some(CustomerServiceFailure.invalidInput),
      ));
      return;
    }
    final generation = ++_generation;
    emit(const CustomerServiceState(status: CustomerServiceStatus.submitting));
    try {
      final response = await args.api.submitCustomerService(input);
      if (generation != _generation) return;
      emit(CustomerServiceState(
        status: CustomerServiceStatus.succeeded,
        submission: Some(response),
      ));
    } on Object catch (error) {
      if (generation != _generation) return;
      emit(CustomerServiceState(
        status: CustomerServiceStatus.failed,
        failure: Some(_customerServiceFailure(error)),
      ));
    }
  }
}

CustomerServiceFailure _customerServiceFailure(Object error) {
  if (error is DioException) {
    return switch (error.response?.statusCode) {
      401 => CustomerServiceFailure.sessionExpired,
      400 || 422 => CustomerServiceFailure.invalidInput,
      _ => CustomerServiceFailure.retryable,
    };
  }
  return CustomerServiceFailure.retryable;
}
