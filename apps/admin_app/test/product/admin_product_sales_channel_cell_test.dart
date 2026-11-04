import 'package:admin_app/src/product/admin_product_sales_channel_cell.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channels = [
    AdminSalesChannel(id: 'sc_marketplace', name: 'Marketplace'),
    AdminSalesChannel(id: 'sc_web', name: 'Online Store'),
    AdminSalesChannel(id: 'sc_retail', name: 'Retail'),
    AdminSalesChannel(id: 'sc_wholesale', name: 'Wholesale'),
  ];

  test('shows at most the first two channel names', () {
    final presentation = adminProductSalesChannelPresentation(channels);

    expect(presentation.names, 'Marketplace, Online Store');
    expect(
      presentation.overflow.map((channel) => channel.name),
      ['Retail', 'Wholesale'],
    );
  });

  test('keeps zero and two-channel states explicit', () {
    final empty = adminProductSalesChannelPresentation(const []);
    final exact =
        adminProductSalesChannelPresentation(channels.take(2).toList());

    expect(empty.names, isEmpty);
    expect(empty.overflow, isEmpty);
    expect(exact.names, 'Marketplace, Online Store');
    expect(exact.overflow, isEmpty);
  });
}
