import 'dart:convert';
import 'package:flutter_quotes/favorites/bloc/favorite.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

//any class implementing this interface can be used by FavoritesCubit
//to persist the favorites of a user
abstract class FavoritesStorage {
  Future<List<Favorite>> load();
  Future<bool> add(Favorite favorite);
  Future<bool> remove(String id);
}

//Implementation of FavoritesStorage using the hive package
class HiveFavoritesStorage implements FavoritesStorage {
  final _log = Logger('HiveFavoritesStorage');

  final String userId;

  HiveFavoritesStorage({
    required this.userId,
  });

  Box<String>? box;

  Future<bool> _init() async {
    try {
      //TODO do we need to be careful here with the name of the box?
      //e.g. if there are special characters in the userId might this cause errors?
      box = await Hive.openBox<String>('favorites:$userId');
      return true;
    } catch (e) {
      _log.warning('could not init favorites storage');
      return false;
    }
  }

  @override
  Future<bool> add(Favorite favorite) async {
    try {
      await box!.put(favorite.id, jsonEncode(favorite.toMap()));
      return true;
    } catch (e) {
      _log.warning('could not store favorite');
      return false;
    }
  }

  @override
  Future<bool> remove(String id) async {
    if (box == null) {
      if (!await _init()) {
        return false;
      }
    }
    try {
      await box!.delete(id);
      return true;
    } catch (e) {
      _log.warning('could not store favorite');
      return false;
    }
  }

  @override
  Future<List<Favorite>> load() async {
    if (box == null) {
      if (!await _init()) {
        throw Exception('could not init storage');
      }
    }
    try {
      return box!.values
          .map<Favorite>((s) => Favorite.fromMap(jsonDecode(s)))
          .toList();
    } catch (e) {
      _log.warning('could not load favorites');
      rethrow;
    }
  }
}

//can be used for testing
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
