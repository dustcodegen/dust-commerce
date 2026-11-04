import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_return/deps.dart';
import 'package:commerce_server/src/features/admin_return/model.dart';
import 'package:commerce_server/src/features/admin_return/receive_failure.dart';
import 'package:commerce_server/src/features/admin_return/receive_service.dart';
import 'package:dust_server/server.dart';

const JsonExtractable<AdminReceiveReturn> _body =
    JsonExtractable(AdminReceiveReturn.fromJson);

/// `POST /admin/returns/{id}/receive` confirms physical receipt atomically.
Future<Result<AdminReturnResponse, Rejection>> receiveAdminReturnHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A return id is required'));
  }
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminReturnDeps(request);
  if (state case Err(:final error)) return Err(error);
  final result = await receiveAdminReturn(
    (state as Ok<AdminReturnDeps, Rejection>).value,
    id,
    (decoded as Ok<AdminReceiveReturn, Rejection>).value,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: AdminReturnReceiveRejected()) =>
      const Err(Rejection.status(422, 'Return receipt quantities are invalid')),
    Err(error: AdminReturnReceiveStorage()) => const Err(Rejection.internal()),
  };
}
