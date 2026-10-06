import 'package:commerce_app/src/features/catalog/view/listing_pagination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shows every page when seven or fewer exist', () {
    expect(_labels(listingPaginationItems(3, 7)), [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
    ]);
  });

  test('bounds the leading, middle, and trailing page ranges', () {
    expect(
      _labels(listingPaginationItems(2, 10)),
      ['1', '2', '3', '4', '5', '...', '10'],
    );
    expect(
      _labels(listingPaginationItems(6, 12)),
      ['1', '...', '5', '6', '7', '...', '12'],
    );
    expect(
      _labels(listingPaginationItems(9, 10)),
      ['1', '...', '6', '7', '8', '9', '10'],
    );
  });

  test('matches current StoreHits search pagination window', () {
    expect(
      _labels(listingPaginationItems(2, 10, search: true)),
      ['1', '2', '3', '4', '...', '10'],
    );
    expect(
      _labels(listingPaginationItems(4, 10, search: true)),
      ['1', '2', '3', '4', '5', '6', '...', '10'],
    );
    expect(
      _labels(listingPaginationItems(6, 12, search: true)),
      ['1', '...', '4', '5', '6', '7', '8', '...', '12'],
    );
    expect(
      _labels(listingPaginationItems(9, 10, search: true)),
      ['1', '...', '7', '8', '9', '10'],
    );
  });
}

List<String> _labels(List<ListingPaginationItem> items) => [
      for (final item in items)
        switch (item) {
          ListingPage(:final page) => '$page',
          ListingEllipsis() => '...',
        },
    ];
