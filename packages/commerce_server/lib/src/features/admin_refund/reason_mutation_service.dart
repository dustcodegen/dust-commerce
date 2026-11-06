import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_refund/reason_failure.dart';
import 'package:commerce_server/src/features/admin_refund/reason_model.dart';
import 'package:commerce_server/src/features/admin_refund/reason_repository.dart';
import 'package:dust_dart/db.dart';

/// Creates one merchant-managed refund reason.
Future<Result<AdminRefundReasonResponse, AdminRefundReasonError>>
    createAdminRefundReason(
  AdminRefundReasonRepository reasons,
  AdminCreateRefundReason input, {
  required String Function() nextId,
}) async {
  final result = await reasons.insert(
    nextId(),
    input.label.trim(),
    input.code.trim().toLowerCase(),
    _description(input.descriptionValue),
  );
  if (result case Err(:final error)) {
    return Err(AdminRefundReasonStorage(error));
  }
  final value = (result as Ok<AdminRefundReasonResponse?, SqlxError>).value;
  return value == null
      ? const Err(AdminRefundReasonRejected(
          AdminRefundReasonFailure.codeConflict,
        ))
      : Ok(value);
}

/// Updates one active merchant-managed refund reason.
Future<Result<AdminRefundReasonResponse, AdminRefundReasonError>>
    updateAdminRefundReason(
  AdminRefundReasonRepository reasons,
  String id,
  AdminUpdateRefundReason input,
) async {
  final result = await reasons.update(
    id,
    input.label.trim(),
    input.code.trim().toLowerCase(),
    _description(input.descriptionValue),
  );
  if (result case Err(:final error)) {
    return Err(AdminRefundReasonStorage(error));
  }
  final value = (result as Ok<AdminRefundReasonResponse?, SqlxError>).value;
  return value == null
      ? const Err(AdminRefundReasonRejected(
          AdminRefundReasonFailure.notFound,
        ))
      : Ok(value);
}

/// Retires one active merchant-managed refund reason.
Future<Result<String, AdminRefundReasonError>> retireAdminRefundReason(
  AdminRefundReasonRepository reasons,
  String id,
) async {
  final result = await reasons.retire(id);
  if (result case Err(:final error)) {
    return Err(AdminRefundReasonStorage(error));
  }
  final value = (result as Ok<String?, SqlxError>).value;
  return value == null
      ? const Err(AdminRefundReasonRejected(
          AdminRefundReasonFailure.notFound,
        ))
      : Ok(value);
}

String? _description(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
