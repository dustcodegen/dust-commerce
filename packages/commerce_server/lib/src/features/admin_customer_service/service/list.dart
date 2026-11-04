import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer_service/model.dart';
import 'package:commerce_server/src/features/admin_customer_service/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of merchant-visible support requests.
Future<Result<AdminCustomerServiceListResponse, SqlxError>>
    listAdminCustomerService(
  AdminCustomerServiceRepository requests, {
  required String query,
  required List<AdminCustomerServiceStatus> statuses,
  required AdminCustomerServiceOrder order,
  required int limit,
  required int offset,
}) async {
  final statusNames =
      statuses.map(const AdminCustomerServiceStatusCodec().serialize).join(',');
  final page = await requests.list(
    query,
    statusNames,
    order.parameter,
    limit,
    offset,
  );
  if (page case Err(:final error)) return Err(error);
  final count = await requests.count(query, statusNames);
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminCustomerServiceListResponse(
    requests: (page as Ok<List<AdminCustomerServiceResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}
