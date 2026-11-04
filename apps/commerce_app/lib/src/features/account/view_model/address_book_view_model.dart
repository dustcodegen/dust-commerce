import 'dart:async';

import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/account/model/address_book_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'address_book_view_model.g.dart';

/// Dependencies for customer address-book state.
final class AddressBookViewModelArgs extends ViewModelArgs {
  /// Creates address-book dependencies.
  const AddressBookViewModelArgs({required this.api, super.observer});

  /// Generated store API with Dio-owned authorization.
  final CommerceApi api;
}

/// Owns authenticated address listing and mutations.
@ViewModel(state: AddressBookState, args: AddressBookViewModelArgs)
class AddressBookViewModel extends $AddressBookViewModel {
  /// Creates the address-book state machine.
  AddressBookViewModel(super.args);

  var _generation = 0;

  /// Clears customer-owned data when the authenticated identity changes.
  void reset() {
    _generation++;
    emit(const AddressBookState());
  }

  /// Loads the customer's active addresses.
  Future<void> load() async {
    if (state.isBusy) return;
    final generation = _generation;
    _start(AddressBookOperation.load, AddressBookStatus.loading);
    try {
      final (view, regions) = await (
        args.api.customerAddresses(),
        args.api.regions(),
      ).wait;
      if (generation != _generation) return;
      _ready(view.addresses, regions: regions.regions);
    } on Exception catch (error) {
      if (generation == _generation) {
        _fail(AddressBookOperation.load, error);
      }
    }
  }

  /// Creates one address from validated form input.
  Future<bool> create(CustomerAddressInput input) async {
    if (state.isBusy) return false;
    final generation = _generation;
    _start(AddressBookOperation.create, AddressBookStatus.mutating);
    try {
      final address = await args.api.createCustomerAddress(input);
      if (generation != _generation) return false;
      _ready(_merged(address, append: true));
      return true;
    } on Exception catch (error) {
      if (generation != _generation) return false;
      _fail(AddressBookOperation.create, error);
      return false;
    }
  }

  /// Replaces one owned address.
  Future<bool> update(String id, CustomerAddressInput input) async {
    if (state.isBusy) return false;
    final generation = _generation;
    _start(AddressBookOperation.update, AddressBookStatus.mutating);
    try {
      final address = await args.api.updateCustomerAddress(id, input);
      if (generation != _generation) return false;
      _ready(_merged(address));
      return true;
    } on Exception catch (error) {
      if (generation != _generation) return false;
      _fail(AddressBookOperation.update, error);
      return false;
    }
  }

  /// Soft-deletes one owned address.
  Future<bool> delete(String id) async {
    if (state.isBusy) return false;
    final generation = _generation;
    _start(AddressBookOperation.delete, AddressBookStatus.mutating);
    try {
      await args.api.deleteCustomerAddress(id);
      if (generation != _generation) return false;
      _ready(state.addresses.where((address) => address.id != id).toList());
      return true;
    } on Exception catch (error) {
      if (generation != _generation) return false;
      _fail(AddressBookOperation.delete, error);
      return false;
    }
  }

  List<CustomerAddressView> _merged(
    CustomerAddressView address, {
    bool append = false,
  }) {
    final values = <CustomerAddressView>[];
    for (final current in state.addresses) {
      if (current.id == address.id) {
        values.add(address);
      } else {
        values.add(current.copyWith(
          isDefaultShipping:
              !address.isDefaultShipping && current.isDefaultShipping,
          isDefaultBilling:
              !address.isDefaultBilling && current.isDefaultBilling,
        ));
      }
    }
    if (append) values.add(address);
    return values;
  }

  void _start(AddressBookOperation operation, AddressBookStatus status) => emit(
        state.copyWith(
          status: status,
          operation: Some(operation),
          message: const None<String>(),
        ),
      );

  void _ready(
    List<CustomerAddressView> addresses, {
    List<Region>? regions,
  }) =>
      emit(AddressBookState(
        addresses: addresses,
        regions: regions ?? state.regions,
        hasLoaded: true,
        status: AddressBookStatus.ready,
      ));

  void _fail(AddressBookOperation operation, Object error) => emit(
        state.copyWith(
          status: AddressBookStatus.failed,
          operation: Some(operation),
          message: Some(_addressMessageOf(error)),
        ),
      );
}

String _addressMessageOf(Object error) =>
    error is DioException && error.response?.statusCode == 422
        ? 'Check the address information and try again.'
        : 'We could not update your address book. Please try again.';
