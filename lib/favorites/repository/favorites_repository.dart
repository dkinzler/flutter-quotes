import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/repository/storage/favorites_storage.dart';

/*
FavoritesRepository
* maintains the list of favorite quotes of the currently logged in user
* persists the favorites using an instance of FavoritesStorage
* make the favorites available to other components of the app, e.g. application/ui-level blocs and cubits

Other classes can call getFavorites() to obtain a stream of the current favorites, that can be listened to for changes.

The favorites of the app are represented using an instance of class Favorites, which consists of:
* the list of quotes the user favorited
* a status field indicating whether or not the favorites were successfully loaded from storage

Why did we choose to include the status field?
For a simple storage backend, that writes the favorites to the disk of the device, we can expect that loading the favorites will almost
always succeed, unless the device or disk broken.
Although in the future we might add a storage backend that stores the favorites in the cloud. Then it might happen frequently, e.g. if the device has no internet connection,
that the favorites can not be loaded.
The alternative to having an explicit status field, would be to make getFavorites() directly return a Stream<List<Favorite>> with the current list of favorites.
If there is an error while loading the favorites from storage, we could add an error the stream.
However, the responsibility to figure out what is currently happening (does the user not have any favorites? have they not been loaded yet? did the loading operation fail?), is then shifted
to the upstream components like Blocs and Cubits, which are typically intersted in this information. E.g. on a UI screen that shows the list of favorites, possibly filtered and sorted,
we would want to see a progress/loading indicator if the favorites are currently being loaded, or an error message and retry button if the favorites could not be retrieved.
We believe it makes it easier to understand and use FavoritesRepository in upstream Blocs/Cubits, if the current status is explicitely represented.
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

  //this will be the state while no user is logged in.
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
  final FavoritesStorageType _storageType;
  FavoritesStorage? _storage;

  final FavoritesStorageBuilder _storageBuilder;

  static FavoritesStorage _defaultStorageBuilder(
      FavoritesStorageType type, String userId) {
    return FavoritesStorageFactory.buildFavoritesStorage(type, userId);
  }

  FavoritesRepository({
    FavoritesStorageType storageType = FavoritesStorageType.hive,
    //can be used e.g. in testing to inject a mock storage instance
    FavoritesStorageBuilder storageBuilder = _defaultStorageBuilder,
  })  : _storageType = storageType,
        _storageBuilder = storageBuilder;

  //need to call init() every time the logged in user changes.
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
    } catch (e) {
      _add(const Favorites.error());
    }
  }

  Future<bool> add(Favorite favorite) async {
    if (!_favorites.status.isLoaded) {
      return false;
    }
    try {
      //only emit the new favorites if the change is successfully persisted using storage
      var success = await _storage!.add(favorite);
      if (success) {
        var newFavorites = [..._favorites.favorites];
        var index = newFavorites.indexWhere((f) => f.id == favorite.id);
        //update favorite if it was already contained in the list
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
    } catch (e) {
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
      //only emit the new favorites if the change is successfully persisted using storage
      var success = await _storage!.remove(id);
      if (success) {
        var newFavorites =
            _favorites.favorites.where((f) => f.id != id).toList();
        _add(Favorites.loaded(favorites: newFavorites));
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
