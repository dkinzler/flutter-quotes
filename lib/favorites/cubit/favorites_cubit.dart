import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/repository/favorites_repository.dart';
import 'package:flutter_quotes/quote/quote.dart';

/*
FavoritesCubit provides to the application:
* the list of favorites of the user
* the ability to add/remove/toggle/find favorites

Although FavoritesRepository could be used directly to achieve most of these things, FavoritesCubit can provide
convenience methods that are tailored to the UI/application features it is used for.
The separation keeps FavoritesRepsitory clean and simple, no requirements and details from specific application features leak into it.

FavoritesCubit is not concerned with sorting, searching and filtering the favorites, see FilteredFavoritesBloc for this.
*/

class FavoritesState extends Equatable {
  final Status status;
  final List<Favorite> favorites;

  bool get isEmpty => favorites.isEmpty;

  bool containsQuote(Quote quote) => contains(quote.id);

  bool containsFavorite(Favorite favorite) => contains(favorite.id);

  bool contains(String id) {
    return favorites.any((i) => i.id == id);
  }

  const FavoritesState({required this.status, required this.favorites});

  @override
  List<Object?> get props => [status, favorites];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository favoritesRepository;

  FavoritesCubit({required this.favoritesRepository})
      : super(const FavoritesState(
          status: Status.loading,
          favorites: [],
        )) {
    _init();
  }

  StreamSubscription? _favoritesRepositorySubscription;

  void _init() {
    _favoritesRepositorySubscription?.cancel();
    _favoritesRepositorySubscription =
        favoritesRepository.getFavorites().listen((f) {
      emit(FavoritesState(status: f.status, favorites: f.favorites));
    });
  }

  //can be used to reload the favorites, e.g. when an error occurs somewhere
  Future<void> reload() {
    return favoritesRepository.load();
  }

  Future<bool> add(Quote quote) async {
    var favorite = Favorite.fromQuote(quote: quote);
    return favoritesRepository.add(favorite);
  }

  Future<bool> remove({Quote? quote, Favorite? favorite}) async {
    String? id = quote?.id ?? favorite?.id;
    if (id == null) {
      return false;
    }
    return removeById(id);
  }

  Future<bool> removeById(String id) async {
    return favoritesRepository.remove(id);
  }

  Future<bool> toggle(Quote quote) {
    if (state.containsQuote(quote)) {
      return remove(quote: quote);
    } else {
      return add(quote);
    }
  }
}
