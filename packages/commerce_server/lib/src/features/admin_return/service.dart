import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_return/model.dart';
import 'package:commerce_server/src/features/admin_return/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of merchant-visible returns.
Future<Result<AdminReturnListResponse, SqlxError>> listAdminReturns(
  AdminReturnRepository returns, {
  required String orderId,
  required List<AdminReturnStatus> statuses,
  required int limit,
  required int offset,
}) async {
  final statusNames = statuses
      .map((status) => const AdminReturnStatusCodec().serialize(status))
      .join(',');
  final page = await returns.list('', orderId, statusNames, limit, offset);
  if (page case Err(:final error)) return Err(error);
  final count = await returns.count(orderId, statusNames);
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminReturnListResponse(
    returns: (page as Ok<List<AdminReturnResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}
