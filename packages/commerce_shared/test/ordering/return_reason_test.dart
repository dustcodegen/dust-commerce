import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('return-reason list round-trips only the Store allowlist', () {
    final view = ReturnReasonListView.fromJson({
      'return_reasons': [
        {
          'id': 'reason_damaged',
          'value': 'damaged',
          'label': 'Damaged',
          'description': 'The item arrived damaged.',
          'parent_return_reason_id': null,
          'created_at': '2026-09-14T12:00:00.000Z',
          'updated_at': '2026-09-14T12:00:00.000Z',
        },
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    });

    expect(view.count, 1);
    expect(view.limit, 20);
    expect(view.offset, 0);
    expect(view.returnReasons.single.description,
        const Some('The item arrived damaged.'));
    expect(
        view.returnReasons.single.parentReturnReasonId, const None<String>());
    expect(view.returnReasons.single.createdAt.isUtc, isTrue);
    expect(
      view.toJson().keys,
      unorderedEquals({'return_reasons', 'count', 'limit', 'offset'}),
    );
    expect(
      view.returnReasons.single.toJson().keys,
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
}
