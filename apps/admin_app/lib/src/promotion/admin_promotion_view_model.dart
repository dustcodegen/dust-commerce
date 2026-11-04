import 'package:admin_app/src/promotion/admin_promotion_api.dart';
import 'package:admin_app/src/promotion/admin_promotion_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_promotion_view_model.g.dart';
part 'admin_promotion_filters.dart';

/// Dependencies for the promotions table.
final class AdminPromotionViewModelArgs extends ViewModelArgs {
  /// Creates promotion-list dependencies.
  const AdminPromotionViewModelArgs({required this.api, super.observer});

  /// Generated admin-only API client.
  final AdminPromotionApi api;
}

/// Loads and searches merchant promotions.
@ViewModel(state: AdminPromotionState, args: AdminPromotionViewModelArgs)
final class AdminPromotionViewModel extends $AdminPromotionViewModel {
  /// Creates the promotion state machine.
  AdminPromotionViewModel(super.args);

  int _revision = 0;

  /// Loads the first page for [query].
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Loads one bounded promotion page.
  Future<void> load({
    String? query,
    int? offset,
    AdminDateFilter? createdAt,
    AdminDateFilter? updatedAt,
    AdminPromotionOrder? order,
  }) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final nextCreatedAt = createdAt ?? state.createdAt;
    final nextUpdatedAt = updatedAt ?? state.updatedAt;
    final nextOrder = order ?? state.order;
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminPromotionLoadStatus.loading,
      offset: nextOffset,
      query: nextQuery,
      createdAt: nextCreatedAt,
      updatedAt: nextUpdatedAt,
      order: nextOrder,
      failure: const None(),
    ));
    try {
      final page = await args.api.list(
        nextQuery,
        nextCreatedAt.isEmpty ? '' : nextCreatedAt.parameter,
        nextUpdatedAt.isEmpty ? '' : nextUpdatedAt.parameter,
        nextOrder.parameter,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(AdminPromotionState(
        status: AdminPromotionLoadStatus.ready,
        promotions: page.promotions,
        count: page.count,
        limit: page.limit,
        offset: page.offset,
        query: nextQuery,
        createdAt: nextCreatedAt,
        updatedAt: nextUpdatedAt,
        order: nextOrder,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load promotions. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load promotions. Try again.');
    }
  }

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  void _fail(String message) => emit(state.copyWith(
        status: AdminPromotionLoadStatus.failed,
        failure: Some(message),
      ));
}
