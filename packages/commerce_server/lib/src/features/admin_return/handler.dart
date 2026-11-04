import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_return/deps.dart';
import 'package:commerce_server/src/features/admin_return/model.dart';
import 'package:commerce_server/src/features/admin_return/query.dart';
import 'package:commerce_server/src/features/admin_return/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/returns` lists returns for a proven merchant.
Future<Result<AdminReturnListResponse, Rejection>> listAdminReturnsHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminReturnDeps(request);
  if (state case Err(:final error)) return Err(error);
  final query = adminReturnQueryOf(request);
  if (query case Err(:final error)) return Err(error);
  final paging = pagingOf(request);
  final deps = (state as Ok<AdminReturnDeps, Rejection>).value;
  final value = (query as Ok<AdminReturnQuery, Rejection>).value;
  final result = await listAdminReturns(
    deps.returns,
    orderId: value.orderId,
    statuses: value.statuses,
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
