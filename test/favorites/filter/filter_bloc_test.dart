import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/repository/favorites_repository.dart'
    hide Status;
import 'package:flutter_quotes/favorites/repository/storage/favorites_storage.dart';
import 'package:flutter_quotes/quote/model/quote.dart';
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
        tags: ['tag3', 'tag4']),
    Quote(text: 'ghi', author: '789', source: 'test', sourceId: '3'),
  ];

  List<Favorite> exampleFavorites =
      exampleQuotes.map<Favorite>((q) => Favorite.fromQuote(quote: q)).toList();

  var f1 = exampleFavorites[0];
  var f2 = exampleFavorites[1];

  group('FilteredFavoritesBloc', () {
    late FilteredFavoritesBloc filteredFavoritesBloc;
    late FavoritesRepository favoritesRepository;

    setUp(() {
      favoritesRepository =
          FavoritesRepository(storageType: FavoritesStorageType.mock);
      filteredFavoritesBloc = FilteredFavoritesBloc(
          favoritesRepository: favoritesRepository, debounceTime: null);
    });

    blocTest<FilteredFavoritesBloc, FilteredFavoritesState>(
      'changes state correctly when FavoritesRepository updates',
      build: () => filteredFavoritesBloc,
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await favoritesRepository.init('test');
        await favoritesRepository.add(f1);
        // wait for events to be processed
        await Future.delayed(const Duration(milliseconds: 10));
        await favoritesRepository.remove(f1.id);
      },
      expect: () => [
        const FilteredFavoritesState(
          status: Status.loaded,
          favorites: [],
          filteredFavorites: [],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          favorites: [f1],
          filteredFavorites: const [],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          favorites: [f1],
          filteredFavorites: [f1],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          favorites: const [],
          filteredFavorites: [f1],
        ),
        const FilteredFavoritesState(
          status: Status.loaded,
          favorites: [],
          filteredFavorites: [],
        ),
      ],
    );

    blocTest<FilteredFavoritesBloc, FilteredFavoritesState>(
      'seach term filter is applied',
      build: () => filteredFavoritesBloc,
      seed: () => FilteredFavoritesState(
        status: Status.loaded,
        favorites: [f1],
        filteredFavorites: [f1],
      ),
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        // this should match f1
        c.add(const SearchTermChanged(searchTerm: 'abc'));
        // this should match nothing
        c.add(const SearchTermChanged(searchTerm: '%&/'));
      },
      expect: () => [
        FilteredFavoritesState(
          status: Status.loaded,
          filters: const Filters(searchTerm: 'abc'),
          favorites: [f1],
          filteredFavorites: [f1],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          filters: const Filters(searchTerm: '%&/'),
          favorites: [f1],
          filteredFavorites: [f1],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          filters: const Filters(searchTerm: '%&/'),
          favorites: [f1],
          filteredFavorites: const [],
        ),
      ],
    );

    blocTest<FilteredFavoritesBloc, FilteredFavoritesState>(
      'tag filters work',
      build: () => filteredFavoritesBloc,
      seed: () => FilteredFavoritesState(
        status: Status.loaded,
        favorites: [f1, f2],
        filteredFavorites: [f1, f2],
      ),
      wait: const Duration(milliseconds: 40),
      act: (c) async {
        // should match just f1
        c.add(const FilterTagAdded(tag: 'tag1'));
        await Future.delayed(const Duration(milliseconds: 10));
        // should match both f1 and f2
        c.add(const FilterTagAdded(tag: 'tag3'));
        await Future.delayed(const Duration(milliseconds: 10));
        // match only f2
        c.add(const FilterTagRemoved(tag: 'tag1'));
      },
      expect: () => [
        FilteredFavoritesState(
          status: Status.loaded,
          filters: const Filters(tags: ['tag1']),
          favorites: [f1, f2],
          filteredFavorites: [f1, f2],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          filters: const Filters(tags: ['tag1']),
          favorites: [f1, f2],
          filteredFavorites: [f1],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          filters: const Filters(tags: ['tag1', 'tag3']),
          favorites: [f1, f2],
          filteredFavorites: [f1],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          filters: const Filters(tags: ['tag1', 'tag3']),
          favorites: [f1, f2],
          filteredFavorites: [f1, f2],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          filters: const Filters(tags: ['tag3']),
          favorites: [f1, f2],
          filteredFavorites: [f1, f2],
        ),
        FilteredFavoritesState(
          status: Status.loaded,
          filters: const Filters(tags: ['tag3']),
          favorites: [f1, f2],
          filteredFavorites: [f2],
        ),
      ],
    );
  });
}
