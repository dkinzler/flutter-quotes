import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/repository/favorites_repository.dart';
import 'package:flutter_quotes/favorites/repository/storage/storage.dart';
import 'package:flutter_quotes/quote/model/quote.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFavoritesStorage extends Mock implements FavoritesStorage {}

void main() {
  var timeNow = DateTime(2022);
  currentTime = () => timeNow;

  var exampleFavorites = <Favorite>[
    Favorite.fromQuote(
        quote: const Quote(text: 'abc', author: 'xyz', source: 'test')),
    Favorite.fromQuote(
        quote: const Quote(text: 'xyz', author: 'abc', source: 'test')),
  ];

  group('FavoritesRepository', () {
    late FavoritesRepository r;
    late FavoritesStorage s;

    setUp(() {
      s = MockFavoritesStorage();
      r = FavoritesRepository(storageBuilder: (_, __) => s);
    });

    test('emits correct favorites when loading from storage succeeds',
        () async {
      expectLater(
          r.getFavorites(),
          emitsInOrder([
            const Favorites.initial(),
            const Favorites(status: Status.loading, favorites: []),
            Favorites.loaded(favorites: exampleFavorites),
          ]));

      when(() => s.load()).thenAnswer((_) async => exampleFavorites);
      await r.init('test');
      verify(() => s.load()).called(1);
    });

    test('emits correct favorites when loading from storage fails', () async {
      expectLater(
          r.getFavorites(),
          emitsInOrder([
            const Favorites.initial(),
            const Favorites(status: Status.loading, favorites: []),
            const Favorites(status: Status.error, favorites: []),
          ]));

      when(() => s.load()).thenThrow(Exception());
      await r.init('test');
      verify(() => s.load()).called(1);
    });

    test('emits correct favorites when new favorite are added and removed',
        () async {
      var favorite = exampleFavorites.first;
      var otherFavorite = exampleFavorites.last;

      expectLater(
          r.getFavorites(),
          emitsInOrder([
            const Favorites.initial(),
            const Favorites(status: Status.loading, favorites: []),
            const Favorites.loaded(favorites: []),
            Favorites.loaded(favorites: [favorite]),
            Favorites.loaded(favorites: [favorite, otherFavorite]),
            Favorites.loaded(favorites: [otherFavorite]),
            const Favorites.loaded(favorites: []),
          ]));

      when(() => s.load()).thenAnswer((_) async => []);
      await r.init('test');
      verify(() => s.load()).called(1);

      when(() => s.add(favorite)).thenAnswer((_) async => true);
      var success = await r.add(favorite);
      expect(success, true);
      verify(() => s.add(favorite)).called(1);

      //when storage can't add favorite, nothing happens
      when(() => s.add(otherFavorite)).thenAnswer((_) async => false);
      success = await r.add(otherFavorite);
      expect(success, false);
      verify(() => s.add(otherFavorite)).called(1);

      //now it works
      when(() => s.add(otherFavorite)).thenAnswer((_) async => true);
      success = await r.add(otherFavorite);
      expect(success, true);
      verify(() => s.add(otherFavorite)).called(1);

      //lets remove them
      when(() => s.remove(favorite.id)).thenAnswer((_) async => true);
      success = await r.remove(favorite.id);
      expect(success, true);
      verify(() => s.remove(favorite.id)).called(1);

      //should do nothing
      when(() => s.remove(otherFavorite.id)).thenAnswer((_) async => false);
      success = await r.remove(otherFavorite.id);
      expect(success, false);
      verify(() => s.remove(otherFavorite.id)).called(1);

      when(() => s.remove(otherFavorite.id)).thenAnswer((_) async => true);
      success = await r.remove(otherFavorite.id);
      expect(success, true);
      verify(() => s.remove(otherFavorite.id)).called(1);
    });

    test('cannot add or remove favorites if favorites have not been loaded',
        () async {
      expectLater(
          r.getFavorites(),
          emitsInOrder([
            const Favorites.initial(),
            const Favorites(status: Status.loading, favorites: []),
            const Favorites(status: Status.error, favorites: []),
          ]));

      when(() => s.load()).thenThrow(Exception());
      await r.init('test');

      var success = await r.add(exampleFavorites.first);
      expect(success, false);
      //storage should not even have been called
      verifyNever(() => s.add(exampleFavorites.first));

      success = await r.remove(exampleFavorites.last.id);
      expect(success, false);
      //storage should not even have been called
      verifyNever(() => s.remove(exampleFavorites.last.id));
    });
  });
}
