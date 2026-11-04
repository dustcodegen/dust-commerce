import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

final Future<Result<AdminOrderDetailResponse, AdminCompleteOrderError>>
    Function(
  AdminOrderDeps deps,
  String orderId,
) _flatBoundary = completeAdminOrder;

void main() {
  test('whole-order completion exposes one typed result boundary', () {
    expect(_flatBoundary, same(completeAdminOrder));
  });
}
