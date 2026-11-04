import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/product_option_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a product-option replacement could not be committed.
enum AdminUpdateProductOptionDetailFailure {
  /// The title or values are empty, too long, or duplicated.
  invalid,

  /// No active product option owns the identifier.
  notFound,

  /// Another global product option already uses the requested title.
  titleConflict,

  /// A live variant still selects one of the removed values.
  valueInUse,
}

/// Atomically replaces one option's title, values, and display order.
Future<
    Result<
        Result<AdminProductOptionDetailResponse,
            AdminUpdateProductOptionDetailFailure>,
        SqlxError>> updateAdminProductOptionDetail(
  CommerceDatabase database,
  String optionId,
  AdminUpdateProductOption input, {
  required String Function() nextId,
}) async {
  final title = input.title.trim();
  final values = input.values.map((value) => value.trim()).toList();
  if (!_validGlobalOption(title, values)) {
    return const Ok(Err(AdminUpdateProductOptionDetailFailure.invalid));
  }
  return database.transaction((tx) async {
    final reads = AdminProductOptionRepository(tx);
    final found = await reads.findById(optionId);
    if (found case Err(:final error)) return Err(error);
    final current = optionOf(
      (found as Ok<AdminProductOptionDetailResponse?, SqlxError>).value,
    );
    if (current case None()) {
      return const Ok(Err(AdminUpdateProductOptionDetailFailure.notFound));
    }
    final detail = (current as Some<AdminProductOptionDetailResponse>).value;
    final writes = AdminProductOptionUpdateRepository(tx);
    final removed =
        detail.values.where((item) => !values.contains(item.value)).toList();
    for (final item in removed) {
      final count = await writes.selectionCount(optionId, item.value);
      if (count case Err(:final error)) return Err(error);
      if ((count as Ok<int, SqlxError>).value > 0) {
        return const Ok(Err(AdminUpdateProductOptionDetailFailure.valueInUse));
      }
    }
    final renamed = await writes.updateTitle(optionId, title);
    if (renamed case Err(:final error)) return Err(error);
    if ((renamed as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
      return const Ok(Err(AdminUpdateProductOptionDetailFailure.titleConflict));
    }
    final links = await writes.productLinks(optionId);
    if (links case Err(:final error)) return Err(error);
    final productLinks =
        (links as Ok<List<AdminProductOptionLink>, SqlxError>).value;
    for (var rank = 0; rank < values.length; rank++) {
      final result = await _upsertGlobalValue(
        writes,
        optionId,
        values[rank],
        rank,
        productLinks,
        nextId,
      );
      if (result case Err(:final error)) return Err(error);
    }
    for (final item in removed) {
      final retired = await writes.retireAvailability(optionId, item.id);
      if (retired case Err(:final error)) return Err(error);
      final deleted = await writes.deleteValue(optionId, item.value);
      if (deleted case Err(:final error)) return Err(error);
      if ((deleted as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        return const Ok(Err(AdminUpdateProductOptionDetailFailure.valueInUse));
      }
    }
    return _readGlobalOption(reads, optionId);
  });
}

Future<Result<void, SqlxError>> _upsertGlobalValue(
  AdminProductOptionUpdateRepository writes,
  String optionId,
  String value,
  int rank,
  List<AdminProductOptionLink> links,
  String Function() nextId,
) async {
  final ranked = await writes.rankValue(optionId, value, rank);
  if (ranked case Err(:final error)) return Err(error);
  final found = await writes.valueId(optionId, value);
  if (found case Err(:final error)) return Err(error);
  final current = optionOf((found as Ok<String?, SqlxError>).value);
  if (current case Some()) return const Ok(null);

  final valueId = nextId();
  final inserted = await writes.insertValue(valueId, optionId, value, rank);
  if (inserted case Err(:final error)) return Err(error);
  for (final link in links) {
    final availability = await writes.insertLinkedAvailability(
      nextId(),
      link.id,
      valueId,
    );
    if (availability case Err(:final error)) return Err(error);
  }
  return const Ok(null);
}

Future<
    Result<
        Result<AdminProductOptionDetailResponse,
            AdminUpdateProductOptionDetailFailure>,
        SqlxError>> _readGlobalOption(
  AdminProductOptionRepository reads,
  String id,
) async {
  final refreshed = await reads.findById(id);
  if (refreshed case Err(:final error)) return Err(error);
  return switch (optionOf(
    (refreshed as Ok<AdminProductOptionDetailResponse?, SqlxError>).value,
  )) {
    Some(:final value) => Ok(Ok(value)),
    None() => const Ok(Err(AdminUpdateProductOptionDetailFailure.notFound)),
  };
}

bool _validGlobalOption(String title, List<String> values) =>
    title.isNotEmpty &&
    title.length <= 255 &&
    values.isNotEmpty &&
    values.every((value) => value.isNotEmpty && value.length <= 255) &&
    values.toSet().length == values.length;
