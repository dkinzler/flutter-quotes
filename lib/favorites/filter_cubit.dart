import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_sample/favorites/favorite.dart';
import 'package:flutter_sample/favorites/favorites_cubit.dart';

//TODO include an option to filter by tag?
//sure, shouldnt be hard

enum FilterStatus {loading, done}

//TODO better name for this
enum Sort {newest, oldest}

class FilterState extends Equatable {
  final FilterStatus status;

  final List<Favorite> filteredFavorites;
  final List<Favorite> favorites;

  final String? searchTerm;
  final Sort sort;

  const FilterState({
    required this.status,
    required this.filteredFavorites,
    required this.favorites,
    this.searchTerm,
    this.sort = Sort.newest,
  });

  @override
  List<Object?> get props => [status, filteredFavorites, favorites, searchTerm, sort];

  FilterState copyWith({
    FilterStatus? status,
    List<Favorite>? filteredFavorites,
    List<Favorite>? favorites,
    String? searchTerm,
    Sort? sort,
  }) {
    return FilterState(
      status: status ?? this.status,
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      favorites: favorites ?? this.favorites,
      searchTerm: searchTerm ?? this.searchTerm,
      sort: sort ?? this.sort,
    );
  }
}


//TODO maybe use a bloc?
//that way we can only process the latest change
class FilterCubit extends Cubit<FilterState> {
  final FavoritesCubit favoritesCubit;
  StreamSubscription? _favoritesCubitSubscription;

  FilterCubit({
    required this.favoritesCubit,
  }) : super(const FilterState(
    status: FilterStatus.loading,
    favorites: [],
    filteredFavorites: [],
  )) {
    _handleFavoritesChanged(favoritesCubit.state.favorites);
    _favoritesCubitSubscription = favoritesCubit.stream.listen((favoritesState) {
      _handleFavoritesChanged(favoritesState.favorites);
    });
  }

  void _handleFavoritesChanged(List<Favorite> favorites) {
    if(favorites == state.favorites) {
      return;
    }
    var filtered = _filterFavorites(favorites, state.searchTerm, state.sort);
    emit(state.copyWith(
      status: FilterStatus.done,
      favorites: favorites, 
      filteredFavorites: filtered,
    ));
  }

  //TODO move this to a separate thread with compute?
  List<Favorite> _filterFavorites(List<Favorite> favorites, String? searchTerm, Sort sort) {
    List<Favorite> filtered = [];
    if(searchTerm != null) {
      for(final favorite in favorites) {
        if(favorite.quote.text.contains(searchTerm) ||
          favorite.quote.author.contains(searchTerm)
        ) {
          filtered.add(favorite);
        }
      }
    } else {
      filtered = List.from(favorites);
    }

    if(sort == Sort.newest) {
      filtered.sort((a, b) => a.timeAdded.compareTo(b.timeAdded));
    } else {
      filtered.sort((a, b) => -1 * a.timeAdded.compareTo(b.timeAdded));
    }
    return filtered;
  }

  //TODO can this code be made more dry?
  void setSearchTerm(String? searchTerm) {
    if(searchTerm == state.searchTerm) {
      return;
    }
    var filtered = _filterFavorites(state.favorites, searchTerm, state.sort);
    emit(state.copyWith(
      status: FilterStatus.done,
      filteredFavorites: filtered,
      searchTerm: searchTerm,
    ));
  }

  void setSort(Sort sort) {
    if(sort == state.sort) {
      return;
    }
    var filtered = _filterFavorites(state.favorites, state.searchTerm, sort);
    emit(state.copyWith(
      status: FilterStatus.done,
      filteredFavorites: filtered,
      sort: sort,
    ));
  }

  @override
  Future<void> close() {
    _favoritesCubitSubscription?.cancel();
    return super.close();
  }
}