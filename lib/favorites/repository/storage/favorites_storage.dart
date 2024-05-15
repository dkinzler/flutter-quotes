import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/repository/storage/storage.dart';

// Any class implementing this interface can be used by FavoritesRepository
// to persist the favorites of a user.
abstract class FavoritesStorage {
  Future<List<Favorite>> load();
  Future<bool> add(Favorite favorite);
  Future<bool> remove(String id);
}

/*
Currently there are only two storage types:
- Hive, which stores the favorites on disk using the "hive" package
- Mock, which doesn't store the favorites at all, they will be gone on app restart
*/
enum FavoritesStorageType { hive, mock }

class FavoritesStorageFactory {
  static FavoritesStorage buildFavoritesStorage(
      FavoritesStorageType storageType, String userId) {
    switch (storageType) {
      case FavoritesStorageType.hive:
        return HiveFavoritesStorage(userId: userId);
      default:
        return MockFavoriteStorage();
    }
  }
}
