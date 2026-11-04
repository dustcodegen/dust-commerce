import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  Promotion percentage(int basisPoints, {String code = 'SAVE'}) => Promotion.of(
        id: 'promo_1',
        code: code,
        type: PromotionType.percentage,
        value: basisPoints,
      );

  Promotion fixed(int amount) => Promotion.of(
        id: 'promo_2',
        code: 'TENOFF',
        type: PromotionType.fixed,
        value: amount,
        currencyCode: 'usd',
      );

  group('Promotion.of', () {
    test('normalises the code, so entry is not case sensitive', () {
      expect(percentage(1000, code: 'save10').code, 'SAVE10');
    });

    test('refuses a percentage above one hundred', () {
      expect(() => percentage(10001), throwsArgumentError);
    });

    test('refuses a value below zero', () {
      expect(() => percentage(-1), throwsArgumentError);
      expect(() => fixed(-1), throwsArgumentError);
    });

    test('refuses a fixed amount with no currency to be fixed in', () {
      expect(
        () => Promotion.of(
          id: 'p',
          code: 'X',
          type: PromotionType.fixed,
          value: 500,
        ),
        throwsArgumentError,
      );
    });
  });

  group('discountOn', () {
    test('takes a percentage of the subtotal', () {
      expect(percentage(1000).discountOn(Money.of(2000, 'usd')),
          Money.of(200, 'usd'));
    });

    test('rounds a fractional minor unit half away from zero', () {
      // 8.75% of 1999 is 174.9125
      expect(percentage(875).discountOn(Money.of(1999, 'usd')),
          Money.of(175, 'usd'));
    });

    test('takes a fixed amount whatever the subtotal', () {
      expect(
          fixed(1000).discountOn(Money.of(2000, 'usd')), Money.of(1000, 'usd'));
    });

    test('never discounts more than the subtotal', () {
      expect(
          fixed(9999).discountOn(Money.of(2000, 'usd')), Money.of(2000, 'usd'));
    });

    test('refuses a subtotal in another currency than a fixed promotion', () {
      expect(() => fixed(500).discountOn(Money.of(2000, 'eur')),
          throwsArgumentError);
    });
  });

  group('validity', () {
    final now = DateTime.utc(2026, 9, 5);

    test('is usable inside its window', () {
      final promo = Promotion.of(
        id: 'p',
        code: 'X',
        type: PromotionType.percentage,
        value: 1000,
        startsAt: DateTime.utc(2026, 9, 1),
        endsAt: DateTime.utc(2026, 9, 30),
      );

      expect(promo.isUsableAt(now), isTrue);
    });

    test('is not usable before it starts or after it ends', () {
      final early = Promotion.of(
        id: 'p',
        code: 'X',
        type: PromotionType.percentage,
        value: 1000,
        startsAt: DateTime.utc(2026, 10, 1),
      );
      final over = Promotion.of(
        id: 'p',
        code: 'X',
        type: PromotionType.percentage,
        value: 1000,
        endsAt: DateTime.utc(2026, 9, 1),
      );

      expect(early.isUsableAt(now), isFalse);
      expect(over.isUsableAt(now), isFalse);
    });

    test('is not usable once its redemption limit is reached', () {
      final spent = Promotion.of(
        id: 'p',
        code: 'X',
        type: PromotionType.percentage,
        value: 1000,
        usageLimit: 2,
        usageCount: 2,
      );

      expect(spent.isUsableAt(now), isFalse);
    });

    test('has no window and no limit by default', () {
      expect(percentage(1000).isUsableAt(now), isTrue);
    });
  });

  group('allocation across lines', () {
    LineItem line(String id, int unitPrice, {int quantity = 1}) => LineItem.of(
          id: id,
          variantId: 'var_$id',
          productId: 'prod_1',
          productHandle: 'thing',
          title: 'Thing',
          unitPrice: Money.of(unitPrice, 'usd'),
          quantity: quantity,
        );

    test('splits proportionally, and the parts equal the whole', () {
      final lines = [line('a', 1000), line('b', 3000)];
      final allocated = allocateDiscount(Money.of(400, 'usd'), lines);

      expect(allocated['a'], Money.of(100, 'usd'));
      expect(allocated['b'], Money.of(300, 'usd'));
      expect(
        allocated.values.reduce((a, b) => a + b),
        Money.of(400, 'usd'),
      );
    });

    test('gives an odd remainder to the largest line, not to nobody', () {
      // 10% of 1000 across three equal lines is 33.33 each: 99, not 100.
      final lines = [line('a', 1000), line('b', 1000), line('c', 1000)];
      final allocated = allocateDiscount(Money.of(100, 'usd'), lines);

      expect(
        allocated.values.reduce((a, b) => a + b),
        Money.of(100, 'usd'),
        reason: 'the parts must equal the whole, or a total will not balance',
      );
    });

    test('never allocates more to a line than the line is worth', () {
      final lines = [line('a', 100), line('b', 5000)];
      final allocated = allocateDiscount(Money.of(5100, 'usd'), lines);

      expect(allocated['a']!, lessThanOrEqualTo(Money.of(100, 'usd')));
      expect(
        allocated.values.reduce((a, b) => a + b),
        Money.of(5100, 'usd'),
      );
    });

    test('allocates nothing across no lines', () {
      expect(allocateDiscount(Money.of(100, 'usd'), const []), isEmpty);
    });
  });
}
