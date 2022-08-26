import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/favorites/bloc/favorite.dart';
import 'package:flutter_quotes/favorites/bloc/favorites_storage.dart';
import 'package:flutter_quotes/quote/quote.dart';
import 'package:logging/logging.dart';

/*
FavoritesCubit maintains the list of quotes a user has favorited.
Whenever a user logs in, the cubit needs to be initialized by called the init() method, which
will try to load the favorites (if any) of the user from storage.
While the init operation is in progress, the "status" field of the cubit state
will be set to LoadingStatus.loading.
If the operation fails the status will be LoadingStatus.error, on sucess LoadingStatus.loaded.
Quotes can only be favorited/unfavoited if the cubit has been successfully initialized.

FavoritesCubit uses a class extending the FavoritesStorage interface to persist the favorites of a user.

FavoritesCubit is not concerned with sorting, seearching and filtering the favorites, see FilterCubit for this.
*/

enum LoadingStatus { loading, error, loaded }

class FavoritesState extends Equatable {
  final LoadingStatus status;
  final List<Favorite> favorites;

  bool containsQuote(Quote quote) {
    var id = quote.id;
    return favorites.any((i) => i.id == id);
  }

  bool containsId(String id) {
    return favorites.any((i) => i.id == id);
  }

  const FavoritesState({required this.status, required this.favorites});

  @override
  List<Object?> get props => [status, favorites];
}

typedef StorageBuilder = FavoritesStorage Function(String userId);

class FavoritesCubit extends Cubit<FavoritesState> {
  final _log = Logger('FavoritesCubit');

  //used by the init() method to build a new instance of FavoritesStorage
  //for the user with the given userId.
  final StorageBuilder _storageBuilder;

  static FavoritesStorage defaultStorageBuilder(String userId) {
    return HiveFavoritesStorage(userId: userId);
  }

  static FavoritesStorage mockStorageBuilder(String userId) {
    return MockFavoriteStorage();
  }

  FavoritesCubit({
    StorageBuilder storageBuilder = defaultStorageBuilder,
  })  : _storageBuilder = storageBuilder,
        super(const FavoritesState(
          status: LoadingStatus.loading,
          favorites: [],
        ));

  FavoritesStorage? _storage;

  void reset() {
    _storage = null;
    emit(const FavoritesState(status: LoadingStatus.loading, favorites: []));
  }

  //should be called everytime the logged-in user changes
  Future<void> init(String userId) async {
    _storage = _storageBuilder(userId);
    return load();
  }

  Future<void> load() async {
    emit(const FavoritesState(
      status: LoadingStatus.loading,
      favorites: [],
    ));
    try {
      List<Favorite> favorites = await _storage!.load();
      emit(FavoritesState(
        status: LoadingStatus.loaded,
        favorites: favorites,
      ));
    } catch (e, st) {
      emit(const FavoritesState(
        status: LoadingStatus.error,
        favorites: [],
      ));
      _log.warning('could not load favorites from storage', e, st);
    }
  }

  Future<bool> add(Quote quote) async {
    if (state.status != LoadingStatus.loaded) {
      return false;
    }
    if (state.containsQuote(quote)) {
      return false;
    }

    var favorite = Favorite.fromQuote(quote: quote);
    try {
      bool success = await _storage!.add(favorite);
      if (success) {
        var favorites = List<Favorite>.from(state.favorites)..add(favorite);
        emit(FavoritesState(
          status: LoadingStatus.loaded,
          favorites: favorites,
        ));
        return true;
      } else {
        return false;
      }
    } catch (e, st) {
      _log.warning('could not add favorite', e, st);
      return false;
    }
  }

  Future<bool> remove(Quote quote) async {
    var id = quote.id;
    return removeById(id);
  }

  Future<bool> removeById(String id) async {
    if (state.status != LoadingStatus.loaded) {
      return false;
    }
    try {
      var success = await _storage!.remove(id);
      if (success) {
        var favorites =
            state.favorites.where((favorite) => favorite.id != id).toList();
        emit(
            FavoritesState(status: LoadingStatus.loaded, favorites: favorites));
        return true;
      } else {
        return false;
      }
    } catch (e, st) {
      _log.warning('could not remove quote', e, st);
      return false;
    }
  }

  Future<bool> toggle(Quote quote) {
    if (state.containsQuote(quote)) {
      return remove(quote);
    } else {
      return add(quote);
    }
  }
}
