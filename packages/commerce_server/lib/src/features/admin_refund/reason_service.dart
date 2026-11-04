import 'package:commerce_server/src/features/admin_refund/reason_model.dart';
import 'package:commerce_server/src/features/admin_refund/reason_repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one stable page of active merchant refund reasons.
Future<Result<AdminRefundReasonListResponse, SqlxError>> listAdminRefundReasons(
  AdminRefundReasonRepository reasons, {
  required String query,
  required int limit,
  required int offset,
}) async {
  final counted = await reasons.count(query);
  if (counted case Err(:final error)) return Err(error);
  final listed = await reasons.list(query, limit, offset);
  if (listed case Err(:final error)) return Err(error);
  return Ok(AdminRefundReasonListResponse(
    refundReasons:
        (listed as Ok<List<AdminRefundReasonResponse>, SqlxError>).value,
    count: (counted as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}
