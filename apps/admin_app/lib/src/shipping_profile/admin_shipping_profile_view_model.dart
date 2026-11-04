import 'package:admin_app/src/shipping_profile/admin_shipping_profile_api.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_shipping_profile_view_model.g.dart';
part 'admin_shipping_profile_filters.dart';

/// Typed result of a shipping-profile deletion attempt.
enum AdminShippingProfileDeleteOutcome {
  /// The profile was retired.
  deleted,

  /// The authenticated admin session has expired.
  expired,

  /// The operation failed for another display-safe reason.
  failed,
}

/// Dependencies for the shipping-profile settings table.
final class AdminShippingProfileViewModelArgs extends ViewModelArgs {
  /// Creates settings dependencies.
  const AdminShippingProfileViewModelArgs({required this.api, super.observer});

  /// Generated admin-only API client.
  final AdminShippingProfileApi api;
}

/// Loads, searches, creates, and retires fulfillment profiles.
@ViewModel(
  state: AdminShippingProfileState,
  args: AdminShippingProfileViewModelArgs,
)
final class AdminShippingProfileViewModel
    extends $AdminShippingProfileViewModel {
  /// Creates the shipping-profile state machine.
  AdminShippingProfileViewModel(super.args);

  int _revision = 0;

  /// Clears display feedback before opening a mutation surface.
  void clearFailure() => emit(state.copyWith(
        status: state.status == AdminShippingProfileStatus.failed
            ? AdminShippingProfileStatus.ready
            : state.status,
        failure: const None(),
      ));

  /// Loads the first page for [query].
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Creates one profile and refreshes the first list page.
  Future<Option<AdminShippingProfile>> create(
    AdminCreateShippingProfile input,
  ) async {
    try {
      final profile = await args.api.create(input);
      await load(query: '', offset: 0);
      return Some(profile);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        409 => 'Another shipping profile already uses this name.',
        422 => 'Enter a shipping profile name and type.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to create this shipping profile. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to create this shipping profile. Try again.');
      return const None();
    }
  }

  /// Deletes one profile and refreshes the first page.
  Future<AdminShippingProfileDeleteOutcome> delete(String id) async {
    try {
      await args.api.delete(id);
      await load(query: '', offset: 0);
      return AdminShippingProfileDeleteOutcome.deleted;
    } on DioException catch (error) {
      return error.response?.statusCode == 401
          ? AdminShippingProfileDeleteOutcome.expired
          : AdminShippingProfileDeleteOutcome.failed;
    } on Object {
      return AdminShippingProfileDeleteOutcome.failed;
    }
  }

  /// Loads one bounded shipping-profile page.
  Future<void> load({
    String? query,
    int? offset,
    String? name,
    String? type,
    AdminDateFilter? createdAt,
    AdminDateFilter? updatedAt,
    AdminShippingProfileOrder? order,
  }) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final nextName = (name ?? state.name).trim();
    final nextType = (type ?? state.type).trim();
    final nextCreatedAt = createdAt ?? state.createdAt;
    final nextUpdatedAt = updatedAt ?? state.updatedAt;
    final nextOrder = order ?? state.order;
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminShippingProfileStatus.loading,
      offset: nextOffset,
      query: nextQuery,
      name: nextName,
      type: nextType,
      createdAt: nextCreatedAt,
      updatedAt: nextUpdatedAt,
      order: nextOrder,
      failure: const None(),
    ));
    try {
      final page = await args.api.list(
        nextQuery,
        nextName,
        nextType,
        nextCreatedAt.isEmpty ? '' : nextCreatedAt.parameter,
        nextUpdatedAt.isEmpty ? '' : nextUpdatedAt.parameter,
        nextOrder.parameter,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(AdminShippingProfileState(
        status: AdminShippingProfileStatus.ready,
        shippingProfiles: page.shippingProfiles,
        count: page.count,
        limit: page.limit,
        offset: page.offset,
        query: nextQuery,
        name: nextName,
        type: nextType,
        createdAt: nextCreatedAt,
        updatedAt: nextUpdatedAt,
        order: nextOrder,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load shipping profiles. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load shipping profiles. Try again.');
    }
  }

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  void _fail(String message) => emit(state.copyWith(
        status: AdminShippingProfileStatus.failed,
        failure: Some(message),
      ));
}
