import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/filter/filter_state.dart';
import 'package:flutter_quotes/quote/quote.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:test/test.dart';

void main() {
  currentTime = () {
    return DateTime(2022);
  };

  List<Quote> exampleQuotes = const [
    Quote(
        text: 'abc',
        author: '123',
        source: 'test',
        sourceId: '1',
        tags: ['tag1', 'tag2']),
    Quote(
        text: 'def',
        author: '456',
        source: 'test',
        sourceId: '2',
        tags: ['tag2', 'tag3']),
    Quote(
        text: 'ghi',
        author: '789a',
        source: 'test',
        sourceId: '3',
        tags: ['tag1', 'tag3']),
  ];

  List<Favorite> exampleFavorites =
      exampleQuotes.map<Favorite>((q) => Favorite.fromQuote(quote: q)).toList();

  group('Filters', () {
    test('empty filters work', () {
      var filters = const Filters();
      var filtered = filters.filter(exampleFavorites);
      expect(filtered, filtered);
    });

    test('filtering by searchTerm works', () {
      //should match first and third (because author contains 'a') quote
      var filters = const Filters(searchTerm: 'a');
      var filtered = filters.filter(exampleFavorites);
      expect(filtered, hasLength(2));
      expect(filtered, [exampleFavorites[0], exampleFavorites[2]]);
    });

    test('filterng by tag works', () {
      var filters = const Filters(tags: ['tag1']);
      var filtered = filters.filter(exampleFavorites);
      expect(filtered, hasLength(2));
      expect(filtered, [exampleFavorites[0], exampleFavorites[2]]);

      filters = const Filters(tags: ['tag2', 'tag3']);
      filtered = filters.filter(exampleFavorites);
      expect(filtered, hasLength(3));
      expect(filtered,
          [exampleFavorites[0], exampleFavorites[1], exampleFavorites[2]]);
    });

    test('filterng by searchTerm and tag works', () {
      var filters = const Filters(searchTerm: 'a', tags: ['tag2']);
      var filtered = filters.filter(exampleFavorites);
      expect(filtered, hasLength(1));
      expect(filtered, [exampleFavorites.first]);
    });

    test('adding and removing tags works', () {
      var filters = const Filters(searchTerm: 'a', tags: ['tag2']);
      filters = filters.copyWithTag('tag1');
      expect(filters, const Filters(searchTerm: 'a', tags: ['tag2', 'tag1']));
      filters = filters.copyWithTag('tag1');
      expect(filters, const Filters(searchTerm: 'a', tags: ['tag2', 'tag1']));
      filters = filters.copyWithTagRemoved('tag2');
      expect(filters, const Filters(searchTerm: 'a', tags: ['tag1']));
    });
  });

  group('Sorting', () {
    var exampleFavorites = <Favorite>[
      Favorite(
        quote: const Quote(
          text: 't1',
          author: 'author',
          source: 'test',
          sourceId: '1',
        ),
        timeAdded: DateTime(2022, 2, 2),
      ),
      Favorite(
        quote: const Quote(
          text: 't2',
          author: 'author',
          source: 'test',
          sourceId: '2',
        ),
        timeAdded: DateTime(2022, 6, 6),
      ),
      Favorite(
        quote: const Quote(
          text: 't3',
          author: 'author',
          source: 'test',
          sourceId: '3',
        ),
        timeAdded: DateTime(2022, 4, 4),
      )
    ];

    test('sorting by newest works', () {
      var favorites = <Favorite>[];
      sort(favorites, SortOrder.newest);
      expect(favorites, <Favorite>[]);

      favorites = List<Favorite>.from(exampleFavorites);
      sort(favorites, SortOrder.newest);
      expect(favorites, <Favorite>[
        exampleFavorites[1],
        exampleFavorites[2],
        exampleFavorites[0],
      ]);
    });

    test('sorting by oldest works', () {
      var favorites = <Favorite>[];
      sort(favorites, SortOrder.oldest);
      expect(favorites, <Favorite>[]);

      favorites = List<Favorite>.from(exampleFavorites);
      sort(favorites, SortOrder.oldest);
      expect(favorites, <Favorite>[
        exampleFavorites[0],
        exampleFavorites[2],
        exampleFavorites[1],
      ]);
    });
  });
}
