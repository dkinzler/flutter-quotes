import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'favorites_storage.dart';

// can be used for testing
class MockFavoriteStorage implements FavoritesStorage {
  @override
  Future<bool> add(Favorite favorite) async {
    return true;
  }

  @override
  Future<List<Favorite>> load() async {
    return [];
  }

  @override
  Future<bool> remove(String id) async {
    return true;
  }
}
