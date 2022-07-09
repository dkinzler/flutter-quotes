import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_sample/favorites/favorite.dart';
import 'package:flutter_sample/quote/quote.dart';

//TODO store favorites, when we need to async load the favorites
//we might need a status field in the cubit state
//also add logging

class FavoritesState extends Equatable {
  final List<Favorite> favorites; 

  bool containsQuote(Quote quote) {
    var id = _idFromQuote(quote);
    return favorites.any((i) => i.id == id);
  }

  const FavoritesState({required this.favorites});

  @override
  List<Object?> get props => [favorites];
}

//TODO how can we detect e.g. on the search page if an image is already favorited
//maybe just by url?
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState(favorites: []));

  void add(Quote quote) {
    var favorite = Favorite(
      id: _idFromQuote(quote),
      quote: quote,
      timeAdded: DateTime.now(),
    );
    var favorites = List<Favorite>.from(state.favorites)..add(favorite);
    emit(FavoritesState(favorites: favorites));
  }

  void remove(Quote quote) {
    var id = _idFromQuote(quote);
    var favorites = state.favorites.where((i) => i.id != id).toList();
    emit(FavoritesState(favorites: favorites));
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