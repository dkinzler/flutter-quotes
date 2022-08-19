import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/favorites/bloc/favorite.dart';
import 'package:flutter_quotes/favorites/filter/filter_state.dart';

class FilteredFavoritesEvent extends Equatable {
  const FilteredFavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesChanged extends FilteredFavoritesEvent {
  final List<Favorite> favorites;

  const FavoritesChanged({required this.favorites});

  @override
  List<Object?> get props => [favorites];
}

class SearchTermChanged extends FilteredFavoritesEvent {
  final String searchTerm;

  const SearchTermChanged({required this.searchTerm});

  @override
  List<Object?> get props => [searchTerm];
}

class FilterTagAdded extends FilteredFavoritesEvent {
  final String tag;

  const FilterTagAdded({required this.tag});

  @override
  List<Object?> get props => [tag];
}

class FilterTagRemoved extends FilteredFavoritesEvent {
  final String tag;

  const FilterTagRemoved({required this.tag});

  @override
  List<Object?> get props => [tag];
}

class SortOrderChanged extends FilteredFavoritesEvent {
  final SortOrder sortOrder;

  const SortOrderChanged({required this.sortOrder});

  @override
  List<Object?> get props => [sortOrder];
}

//will cause the filtered list of favorites to be recomputed based on the current favorites, filters and sort order
class RecomputeFavoritesRequested extends FilteredFavoritesEvent {
  const RecomputeFavoritesRequested();
}
