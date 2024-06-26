import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/repository/storage/favorites_storage.dart';

/*
FavoritesRepository
* maintains the list of favorite quotes of the currently logged in user
* persists the favorites using an instance of FavoritesStorage
* makes the favorites available to other components of the app, e.g. UI blocs and cubits

Other classes can call getFavorites() to obtain a stream of the current favorites that can be listened to for changes.

The favorites of the app are represented using an instance of class Favorites, which consists of:
* the list of quotes the user favorited
* a status field indicating whether or not the favorites were successfully loaded from storage
*/

enum Status {
  initial,
  loading,
  loaded,
  error;

  //helpers to check the current status, this is more convenient than having to write e.g. "status == Status.loading"
  bool get isInitial => this == initial;
  bool get isLoaded => this == loaded;
  bool get isLoading => this == loading;
  bool get isError => this == error;
}

class Favorites extends Equatable {
  final Status status;
  final List<Favorite> favorites;

  const Favorites({
    required this.status,
    required this.favorites,
  });

  const Favorites.initial()
      : status = Status.initial,
        favorites = const [];

  const Favorites.loaded({required this.favorites}) : status = Status.loaded;

  const Favorites.loading()
      : status = Status.loading,
        favorites = const [];

  const Favorites.error()
      : status = Status.error,
        favorites = const [];

  @override
  List<Object?> get props => [status, favorites];

  Favorites copyWith({
    Status? status,
    List<Favorite>? favorites,
  }) {
    return Favorites(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
    );
  }
}

typedef FavoritesStorageBuilder = FavoritesStorage Function(
    FavoritesStorageType, String);

class FavoritesRepository {
  final _log = Logger('FavoritesRepository');

  final FavoritesStorageType _storageType;
  FavoritesStorage? _storage;

  final FavoritesStorageBuilder _storageBuilder;

  static FavoritesStorage _defaultStorageBuilder(
      FavoritesStorageType type, String userId) {
    return FavoritesStorageFactory.buildFavoritesStorage(type, userId);
  }

  FavoritesRepository({
    FavoritesStorageType storageType = FavoritesStorageType.hive,
    // can be used e.g. in testing to inject a mock storage instance
    FavoritesStorageBuilder storageBuilder = _defaultStorageBuilder,
    // initialize the repository for the given user
    String? userId,
  })  : _storageType = storageType,
        _storageBuilder = storageBuilder {
    if (userId != null) init(userId);
  }

  Future<void> init(String userId) async {
    _storage = _storageBuilder(_storageType, userId);
    _add(const Favorites.initial());
    await load();
  }

  void reset() {
    _storage = null;
    _add(const Favorites.initial());
  }

  /*
    To avoid having to manage our own StreamController we could have also made FavoritesRepository a Cubit or Bloc.
    But using BehaviorSubject has the advantage that every new listener will receive the latest element.
    When listening to a Cubit/Bloc we always need to separately call the onData function once for the initial state.
  */
  final _streamController = BehaviorSubject.seeded(const Favorites.initial());

  Stream<Favorites> getFavorites() => _streamController.asBroadcastStream();

  //there should always be a value present, since we seed one initially
  Favorites get _favorites => _streamController.value;

  void _add(Favorites favorites) {
    if (_favorites != favorites) {
      _streamController.add(favorites);
    }
  }

  Future<void> load() async {
    if (_favorites.status.isLoading) {
      return;
    }
    _add(const Favorites.loading());
    try {
      var favorites = await _storage!.load();
      _add(Favorites.loaded(favorites: favorites));
    } catch (e, st) {
      _add(const Favorites.error());
      _log.warning('could not load favorites', e, st);
    }
  }

  Future<bool> add(Favorite favorite) async {
    if (!_favorites.status.isLoaded) {
      return false;
    }
    try {
      // only emit the new favorites if the change is successfully persisted
      var success = await _storage!.add(favorite);
      if (success) {
        var newFavorites = [..._favorites.favorites];
        var index = newFavorites.indexWhere((f) => f.id == favorite.id);
        // update favorite if it was already contained in the list
        if (index >= 0) {
          newFavorites[index] = favorite;
        } else {
          newFavorites.add(favorite);
        }
        _add(Favorites.loaded(favorites: newFavorites));
        return true;
      } else {
        return false;
      }
    } catch (e, st) {
      _log.warning('could not add favorite', e, st);
      return false;
    }
  }

  Future<bool> remove(String id) async {
    if (!_favorites.status.isLoaded) {
      return false;
    }
    if (!_favorites.favorites.any((f) => f.id == id)) {
      return true;
    }
    try {
      // only emit the new favorites if the change is successfully persisted
      var success = await _storage!.remove(id);
      if (success) {
        var newFavorites =
            _favorites.favorites.where((f) => f.id != id).toList();
        _add(Favorites.loaded(favorites: newFavorites));
        return true;
      } else {
        return false;
      }
    } catch (e, st) {
      _log.warning('could not remove favorite', e, st);
      return false;
    }
  }
}
