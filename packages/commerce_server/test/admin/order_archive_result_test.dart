import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

final Future<Result<AdminOrderDetailResponse, AdminArchiveOrderError>> Function(
  AdminOrderDeps deps,
  String orderId,
) _flatBoundary = archiveAdminOrder;

void main() {
  test('whole-order archival exposes one typed result boundary', () {
    expect(_flatBoundary, same(archiveAdminOrder));
  });
}
