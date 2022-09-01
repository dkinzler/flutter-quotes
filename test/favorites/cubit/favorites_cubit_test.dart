import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_quotes/favorites/cubit/cubit.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/repository/favorites_repository.dart'
    hide Status;
import 'package:flutter_quotes/favorites/repository/storage/favorites_storage.dart';
import 'package:flutter_quotes/quote/model/quote.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:test/test.dart';

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

  var f1 = exampleFavorites[0];
  var f2 = exampleFavorites[1];
  var f3 = exampleFavorites[2];

  group('FavoritesCubit', () {
    late FavoritesCubit favoritesCubit;
    late FavoritesRepository favoritesRepository;

    setUp(() {
      favoritesRepository =
          FavoritesRepository(storageType: FavoritesStorageType.mock);
      favoritesCubit = FavoritesCubit(favoritesRepository: favoritesRepository);
    });

    blocTest<FavoritesCubit, FavoritesState>(
      'changes state correctly when FavoritesRepository updates',
      build: () => favoritesCubit,
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await favoritesRepository.init('test');
        await favoritesRepository.add(f1);
        await favoritesRepository.add(f2);
        await favoritesRepository.add(f3);
        await favoritesRepository.remove(f1.id);
        await favoritesRepository.remove(f2.id);
        await favoritesRepository.add(f1);
        await favoritesRepository.remove(f3.id);
      },
      expect: () => [
        const FavoritesState(
          status: Status.loaded,
          favorites: [],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f1],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f1, f2],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f1, f2, f3],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f2, f3],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f3],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f3, f1],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f1],
        ),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'adding, removing, toggling favorites work',
      build: () => favoritesCubit,
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await favoritesRepository.init('test');
        await c.add(f1.quote);
        await c.add(f2.quote);
        await c.remove(favorite: f1);
        await c.remove(quote: f2.quote);
        await c.toggle(f1.quote);
        //need to wait for cubit to process the event from repository
        await Future.delayed(const Duration(milliseconds: 10));
        await c.toggle(f1.quote);
        await Future.delayed(const Duration(milliseconds: 10));
        await c.toggle(f1.quote);
        //this will reset FavoritesRepository
        await c.reload();
      },
      expect: () => [
        const FavoritesState(
          status: Status.loaded,
          favorites: [],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f1],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f1, f2],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f2],
        ),
        const FavoritesState(
          status: Status.loaded,
          favorites: [],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f1],
        ),
        const FavoritesState(
          status: Status.loaded,
          favorites: [],
        ),
        FavoritesState(
          status: Status.loaded,
          favorites: [f1],
        ),
        const FavoritesState(
          status: Status.loading,
          favorites: [],
        ),
        const FavoritesState(
          status: Status.loaded,
          favorites: [],
        ),
      ],
    );
  });
}
