import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_quotes/favorites/bloc/bloc.dart';
import 'package:flutter_quotes/favorites/bloc/favorites_storage.dart';
import 'package:flutter_quotes/quote/quote.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesStorage extends Mock implements FavoritesStorage {}

void main() {
  //the Favorite class contains a DateTime property that holds the time the quote was favorited
  //to make the tests predictable we need to fix the time
  //otherwise it is hard to create expected instances of Favorite that can be compared
  //with the result of some operation/method under test
  currentTime = () {
    return DateTime(2022);
  };

  List<Quote> exampleQuotes = const [
    Quote(text: 'abc', author: '123', source: 'test', sourceId: '1'),
    Quote(text: 'def', author: '456', source: 'test', sourceId: '2'),
    Quote(text: 'ghi', author: '789', source: 'test', sourceId: '3'),
  ];

  List<Favorite> exampleFavorites =
      exampleQuotes.map<Favorite>((q) => Favorite.fromQuote(quote: q)).toList();

  group('FavoritesCubit', () {
    setUpAll(() {
      registerFallbackValue(Favorite.fromQuote(
        quote: const Quote(
          text: 'example',
          author: 'quote',
          source: 'test',
        ),
      ));
    });

    late FavoritesStorage favoritesStorage;

    blocTest<FavoritesCubit, FavoritesState>('loading from storage works',
        setUp: () {
          favoritesStorage = MockFavoritesStorage();
          when(() => favoritesStorage.load())
              .thenAnswer((_) async => exampleFavorites);
        },
        build: () => FavoritesCubit(
              storageBuilder: (userId) => favoritesStorage,
            ),
        wait: const Duration(milliseconds: 10),
        act: (c) => c.init('testUserId'),
        verify: (c) {
          verify(() => favoritesStorage.load()).called(1);
        },
        expect: () => [
              const FavoritesState(
                status: LoadingStatus.loading,
                favorites: [],
              ),
              FavoritesState(
                status: LoadingStatus.loaded,
                favorites: exampleFavorites,
              ),
            ]);

    blocTest<FavoritesCubit, FavoritesState>('loading from storage fails',
        setUp: () {
          favoritesStorage = MockFavoritesStorage();
          when(() => favoritesStorage.load()).thenThrow(Exception());
        },
        build: () => FavoritesCubit(
              storageBuilder: (userId) => favoritesStorage,
            ),
        wait: const Duration(milliseconds: 10),
        act: (c) => c.init('testUserId'),
        verify: (c) {
          verify(() => favoritesStorage.load()).called(1);
        },
        expect: () => [
              const FavoritesState(
                status: LoadingStatus.loading,
                favorites: [],
              ),
              const FavoritesState(
                status: LoadingStatus.error,
                favorites: [],
              ),
            ]);

    blocTest<FavoritesCubit, FavoritesState>(
        'adding favorite fails if storage fails',
        setUp: () {
          favoritesStorage = MockFavoritesStorage();
          when(() => favoritesStorage.load())
              .thenAnswer((_) async => exampleFavorites);
          when(() => favoritesStorage.add(any()))
              .thenAnswer((_) async => false);
        },
        build: () => FavoritesCubit(
              storageBuilder: (userId) => favoritesStorage,
            ),
        wait: const Duration(milliseconds: 10),
        act: (c) async {
          await c.init('testUserId');
          var quote = const Quote(
            text: 'this is a quote',
            author: 'author',
            sourceId: '12',
            source: 'test',
          );
          var success = await c.add(quote);
          expect(success, false);
        },
        verify: (c) {
          verify(() => favoritesStorage.load()).called(1);
          verify(() => favoritesStorage.add(any())).called(1);
        },
        expect: () => [
              const FavoritesState(
                status: LoadingStatus.loading,
                favorites: [],
              ),
              FavoritesState(
                status: LoadingStatus.loaded,
                favorites: exampleFavorites,
              ),
            ]);

    blocTest<FavoritesCubit, FavoritesState>(
      'adding favorite works',
      setUp: () {
        favoritesStorage = MockFavoritesStorage();
        when(() => favoritesStorage.load())
            .thenAnswer((_) async => exampleFavorites);
        when(() => favoritesStorage.add(any())).thenAnswer((_) async => true);
      },
      build: () => FavoritesCubit(
        storageBuilder: (userId) => favoritesStorage,
      ),
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await c.init('testUserId');
        var quote = const Quote(
          text: 'this is a quote',
          author: 'author',
          sourceId: '12',
          source: 'test',
        );
        var success = await c.add(quote);
        expect(success, true);
      },
      verify: (c) {
        verify(() => favoritesStorage.load()).called(1);
        verify(() => favoritesStorage.add(any())).called(1);
      },
      expect: () => [
        const FavoritesState(
          status: LoadingStatus.loading,
          favorites: [],
        ),
        FavoritesState(
          status: LoadingStatus.loaded,
          favorites: exampleFavorites,
        ),
        FavoritesState(
          status: LoadingStatus.loaded,
          favorites: List<Favorite>.from(exampleFavorites)
            ..add(Favorite.fromQuote(
                quote: const Quote(
              text: 'this is a quote',
              author: 'author',
              sourceId: '12',
              source: 'test',
            ))),
        ),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'removing favorite fails then works',
      setUp: () {
        favoritesStorage = MockFavoritesStorage();
        when(() => favoritesStorage.load())
            .thenAnswer((_) async => exampleFavorites);
        when(() => favoritesStorage.remove(any()))
            .thenAnswer((_) async => false);
      },
      build: () => FavoritesCubit(
        storageBuilder: (userId) => favoritesStorage,
      ),
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await c.init('testUserId');
        var favorite = exampleFavorites.first;
        var success = await c.remove(favorite.quote);
        expect(success, false);
        when(() => favoritesStorage.remove(any()))
            .thenAnswer((_) async => true);
        success = await c.remove(favorite.quote);
        expect(success, true);
      },
      verify: (c) {
        verify(() => favoritesStorage.load()).called(1);
        verify(() => favoritesStorage.remove(any())).called(2);
      },
      expect: () => [
        const FavoritesState(
          status: LoadingStatus.loading,
          favorites: [],
        ),
        FavoritesState(
          status: LoadingStatus.loaded,
          favorites: exampleFavorites,
        ),
        FavoritesState(
          status: LoadingStatus.loaded,
          favorites: exampleFavorites.sublist(1),
        ),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggling favorite works',
      setUp: () {
        favoritesStorage = MockFavoritesStorage();
        when(() => favoritesStorage.load())
            .thenAnswer((_) async => exampleFavorites);
        when(() => favoritesStorage.remove(any()))
            .thenAnswer((_) async => true);
        when(() => favoritesStorage.add(any())).thenAnswer((_) async => true);
      },
      build: () => FavoritesCubit(
        storageBuilder: (userId) => favoritesStorage,
      ),
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await c.init('testUserId');
        var f = exampleFavorites.first;
        var success = await c.toggle(f.quote);
        expect(success, true);
        success = await c.toggle(f.quote);
        expect(success, true);
      },
      verify: (c) {
        verify(() => favoritesStorage.load()).called(1);
        verify(() => favoritesStorage.add(any())).called(1);
        verify(() => favoritesStorage.remove(any())).called(1);
      },
      expect: () => [
        const FavoritesState(
          status: LoadingStatus.loading,
          favorites: [],
        ),
        FavoritesState(
          status: LoadingStatus.loaded,
          favorites: exampleFavorites,
        ),
        FavoritesState(
          status: LoadingStatus.loaded,
          favorites: exampleFavorites.sublist(1),
        ),
        FavoritesState(
          status: LoadingStatus.loaded,
          favorites: exampleFavorites.sublist(1)..add(exampleFavorites.first),
        ),
      ],
    );
  });
}
