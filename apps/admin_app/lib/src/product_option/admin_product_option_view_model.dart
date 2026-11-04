import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product_option/admin_product_option_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_product_option_view_model.g.dart';

/// Typed result of a product-option deletion attempt.
enum AdminProductOptionDeleteOutcome {
  /// The unused option was retired.
  deleted,

  /// Active products still expose the option.
  inUse,

  /// The authenticated admin session has expired.
  expired,

  /// The operation failed for another display-safe reason.
  failed,
}

/// Dependencies for the authenticated global-options table.
final class AdminProductOptionViewModelArgs extends ViewModelArgs {
  /// Creates product-option dependencies.
  const AdminProductOptionViewModelArgs({required this.api, super.observer});

  /// Generated admin-only API client.
  final AdminApi api;
}

/// Loads, searches, and pages globally reusable product options.
@ViewModel(
    state: AdminProductOptionState, args: AdminProductOptionViewModelArgs)
final class AdminProductOptionViewModel extends $AdminProductOptionViewModel {
  /// Creates the option list state machine.
  AdminProductOptionViewModel(super.args);

  int _revision = 0;

  /// Loads the first page for [query].
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Creates a global option and refreshes the first list page.
  Future<Option<AdminProductOptionDetail>> create(
    AdminCreateProductOption input,
  ) async {
    try {
      final option = await args.api.createProductOption(input);
      await load(offset: 0);
      return Some(option);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        409 => 'Another option already uses this title.',
        422 => 'Use unique, non-empty option values.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to create this product option. Try again.',
      });
      return const None();
    } catch (_) {
      _fail('Unable to create this product option. Try again.');
      return const None();
    }
  }

  /// Deletes one unused option and refreshes the current list.
  Future<AdminProductOptionDeleteOutcome> delete(String id) async {
    try {
      await args.api.deleteProductOption(id);
      await load(offset: 0);
      return AdminProductOptionDeleteOutcome.deleted;
    } on DioException catch (error) {
      return switch (error.response?.statusCode) {
        409 => AdminProductOptionDeleteOutcome.inUse,
        401 => AdminProductOptionDeleteOutcome.expired,
        _ => AdminProductOptionDeleteOutcome.failed,
      };
    } catch (_) {
      return AdminProductOptionDeleteOutcome.failed;
    }
  }

  /// Loads one bounded global-option page.
  Future<void> load({String? query, int? offset}) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final revision = ++_revision;
    emit(AdminProductOptionState(
      status: AdminProductOptionStatus.loading,
      productOptions: state.productOptions,
      count: state.count,
      limit: state.limit,
      offset: nextOffset,
      query: nextQuery,
    ));
    try {
      final result = await args.api.listProductOptions(
        nextQuery,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(AdminProductOptionState(
        status: AdminProductOptionStatus.ready,
        productOptions: result.productOptions,
        count: result.count,
        limit: result.limit,
        offset: result.offset,
        query: nextQuery,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load product options. Try again.');
    } catch (_) {
      if (revision != _revision) return;
      _fail('Unable to load product options. Try again.');
    }
  }

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  void _fail(String message) => emit(AdminProductOptionState(
        status: AdminProductOptionStatus.failed,
        productOptions: state.productOptions,
        count: state.count,
        limit: state.limit,
        offset: state.offset,
        query: state.query,
        failure: Some(message),
      ));
}
