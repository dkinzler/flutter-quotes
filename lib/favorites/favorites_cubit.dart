import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_sample/favorites/favorite.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

enum InitStatus {loading, error, ready}

class FavoritesState extends Equatable {
  final InitStatus status;
  final List<Favorite> favorites; 

  bool containsQuote(Quote quote) {
    var id = _idFromQuote(quote);
    return favorites.any((i) => i.id == id);
  }

  const FavoritesState({
    required this.status,
    required this.favorites
  });

  @override
  List<Object?> get props => [status, favorites];
}

class FavoritesCubit extends Cubit<FavoritesState> {

  FavoritesCubit() : super(const FavoritesState(
    status: InitStatus.loading,
    favorites: [],
  ));

  late FavoritesStorage _storage;

  Future<void> init(String userId) async {
    _storage = FavoritesStorage(userId: userId);
    load();
  }

  void reset() {
    emit(const FavoritesState(status: InitStatus.loading, favorites: []));
  }

  Future<void> load() async {
    emit(const FavoritesState(
      status: InitStatus.loading,
      favorites: [],
    ));
    try {
      List<Favorite> favorites = await _storage.load();
      emit(FavoritesState(
        status: InitStatus.ready,
        favorites: favorites,
      ));
    } catch(e) {
      emit(const FavoritesState(
        status: InitStatus.error,
        favorites: [],
      ));
    }
  }

  Future<bool> add(Quote quote) async {
    var favorite = Favorite(
      id: _idFromQuote(quote),
      quote: quote,
      timeAdded: DateTime.now(),
    );
    bool success = await _storage.add(favorite);
    //TODO what if it fails, should we change InitStatus to error?
    //just show an error message? and give user the option to reload?
    //i.e. this method would return true/false or throw an exception
    if(success) {
      var favorites = List<Favorite>.from(state.favorites)..add(favorite);
      emit(FavoritesState(
        status: InitStatus.ready,
        favorites: favorites,
      ));
      return true;
    }
    return false;
  }

  Future<void> remove(Quote quote) async {
    var id = _idFromQuote(quote);
    return removeById(id);
  }

  Future<void> removeById(String id) async {
    _storage.remove(id);
    var favorites = state.favorites.where((i) => i.id != id).toList();
    emit(FavoritesState(status: InitStatus.ready, favorites: favorites));
  }

  void toggle(Quote quote) {
    if(state.containsQuote(quote)) {
      remove(quote);
    } else {
      add(quote);
    }
  }
}

//TODO should we force quote api to provide explicit id?
String _idFromQuote(Quote quote) {
  if(quote.id != null) {
    return '${quote.source}:${quote.id}';
  }
  return quote.text;
}

//TODO move this to separate file
//favorites cubit does not need to know about any internals here and whether or not this needs to initialize 
//any stuff
class FavoritesStorage {
  final _log = Logger('FavoritesStorage');

  final String userId;

  FavoritesStorage({
    required this.userId,
  });

  Box<String>? box;

  Future<bool> _init() async {
    try {
      box = await Hive.openBox<String>('favorites:$userId');
      return true;
    } catch(e) {
      _log.warning('could not init favorites storage');
      return false;
    }
  }

  Future<bool> add(Favorite favorite) async {
    if(box == null) {
      var success = await _init();
      if(!success) {
        return false;
      }
    }
    try {
      await box!.put(favorite.id, jsonEncode(favorite.toMap()));
      return true;
    } catch(e) {
      _log.warning('could not store favorite');
      return false;
    }
  }

  Future<bool> remove(String id) async {
    if(box == null) {
      var success = await _init();
      if(!success) {
        return false;
      }
    }
    try {
      await box!.delete(id);
      return true;
    } catch(e) {
      _log.warning('could not store favorite');
      return false;
    }
  }

  Future<List<Favorite>> load() async {
    if(box == null) {
      var success = await _init();
      if(!success) {
        throw Exception('could not init storage');
      }
    }
    try {
      return box!.values.map<Favorite>((s) => Favorite.fromMap(jsonDecode(s))).toList();
    } catch(e) {
      _log.warning('could not load favorites');
      rethrow;
    }
  }
}