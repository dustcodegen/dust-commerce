import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

final Future<Result<AdminOrderDetailResponse, AdminCancelOrderError>> Function(
  AdminOrderDeps deps,
  String orderId,
  String adminId,
) _flatBoundary = cancelAdminOrder;

void main() {
  test('whole-order cancellation exposes one typed result boundary', () {
    expect(_flatBoundary, same(cancelAdminOrder));
  });
}
