import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import '../checkout/support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async {
    harness = await CheckoutHarness.start();
    await queryExecute(r'''
INSERT INTO return_reasons
  (id, value, label, description, parent_return_reason_id, deleted_at)
VALUES
  ('reason_condition', 'condition', 'Item condition',
   'Tell us what happened to the item.', NULL, NULL),
  ('reason_damaged', 'damaged', 'Damaged',
   'The item arrived damaged.', 'reason_condition', NULL),
  ('reason_wrong_size', 'wrong_size', 'Wrong size', NULL, NULL, NULL),
  ('reason_retired', 'retired', 'Retired', NULL, NULL,
   '2026-09-14T12:00:00.000Z')
''', const []).execute(harness.database.executor);
  });
  tearDown(() async => harness.stop());

  test('public list returns active reasons in stable taxonomy order', () async {
    final response = await harness.client.get('/store/return-reasons').send();

    response.assertOk();
    final page = ReturnReasonListView.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(page.count, 3);
    expect(page.limit, 20);
    expect(page.offset, 0);
    expect(
      page.returnReasons.map((reason) => reason.id),
      ['reason_condition', 'reason_damaged', 'reason_wrong_size'],
    );
    expect(page.returnReasons[1].parentReturnReasonId,
        const Some('reason_condition'));
    expect(page.returnReasons[1].createdAt.isUtc, isTrue);
    expect(
      page.returnReasons
          .singleWhere((reason) => reason.id == 'reason_damaged')
          .toJson()
          .keys,
      unorderedEquals({
        'id',
        'value',
        'label',
        'description',
        'parent_return_reason_id',
        'created_at',
        'updated_at',
      }),
    );
  });

  test('pagination reports the full active count', () async {
    final response = await harness.client
        .get('/store/return-reasons?limit=1&offset=1')
        .send();

    response.assertOk();
    final page = ReturnReasonListView.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(page.count, 3);
    expect(page.limit, 1);
    expect(page.offset, 1);
    expect(page.returnReasons.single.id, 'reason_damaged');
  });
}
