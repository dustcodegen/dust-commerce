import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/detail_repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Reads one active order detail, or [None] when it is unavailable.
Future<Result<Option<AdminOrderDetailResponse>, SqlxError>> readAdminOrder(
  AdminOrderDetailRepository orders,
  String id,
) async {
  final result = await orders.find(id);
  return switch (result) {
    Ok(:final value) => Ok(optionOf(value)),
    Err(:final error) => Err(error),
  };
}
