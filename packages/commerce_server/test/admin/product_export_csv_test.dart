import 'package:commerce_server/src/features/admin/product_export_model.dart';
import 'package:commerce_server/src/features/admin/service/export_csv.dart';
import 'package:test/test.dart';

void main() {
  test('quotes CSV boundaries and respects ISO currency exponents', () {
    final csv = adminProductCsv([
      const AdminProductExportRow(
        productId: 'prod_tea',
        handle: 'tea-cup',
        title: 'Tea, "Cup"',
        status: 'published',
        discountable: 1,
        description: 'First line\nSecond line',
        optionsJson: '[{"id":"option_size","title":"Size"}]',
        variantsJson: '[{'
            '"id":"variant_tea","title":"One",'
            '"allow_backorder":false,"manage_inventory":true,'
            '"prices":[{"currency_code":"jpy","amount":1200}],'
            '"option_values":{"option_size":"Single"}'
            '}]',
        imagesJson: '[]',
        tagsJson: '[]',
      ),
    ]);

    expect(csv, contains('Variant Price JPY'));
    expect(csv, contains('"Tea, ""Cup"""'));
    expect(csv, contains('"First line\nSecond line"'));
    expect(csv, contains(',1200,Size,Single'));
    expect(csv, endsWith('\r\n'));
  });
}
