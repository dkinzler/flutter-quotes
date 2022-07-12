import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_sample/favorites/favorite.dart';
import 'package:flutter_sample/favorites/favorites_cubit.dart';


//TODO better name for this
enum Sort {newest, oldest}

class FilterState extends Equatable {
  final List<Favorite> filteredFavorites;
  final List<Favorite> favorites;

  final String? searchTerm;
  final List<String> tags;
  final Sort sort;

  const FilterState({
    required this.filteredFavorites,
    required this.favorites,
    this.searchTerm,
    this.sort = Sort.newest,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [filteredFavorites, favorites, searchTerm, tags, sort];

  FilterState copyWith({
    List<Favorite>? filteredFavorites,
    List<Favorite>? favorites,
    String? searchTerm,
    List<String>? tags,
    Sort? sort,
  }) {
    return FilterState(
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      favorites: favorites ?? this.favorites,
      searchTerm: searchTerm ?? this.searchTerm,
      tags: tags ?? this.tags,
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
    var filtered = _filterFavorites(favorites, state.searchTerm, state.tags, state.sort);
    emit(state.copyWith(
      favorites: favorites, 
      filteredFavorites: filtered,
    ));
  }

  //TODO move this to a separate thread with compute?
  List<Favorite> _filterFavorites(List<Favorite> favorites, String? searchTerm, List<String> tags, Sort sort) {
    List<Favorite> result = [];
    List<Favorite> filtered  = [];

    if(searchTerm != null) {
      for(final favorite in favorites) {
        if(favorite.quote.text.contains(searchTerm) ||
          favorite.quote.author.contains(searchTerm)
        ) {
          filtered.add(favorite);
        }
      }
      result = filtered;
    } else {
      result = List.from(favorites);
    }

    filtered = [];
    if(tags.isNotEmpty) {
      for(final favorite in result) {
        bool contained = false;
        for(final tag in favorite.quote.tags) {
          if(tags.contains(tag)) {
            contained = true;
            break;
          }
        }
        if(contained) {
          filtered.add(favorite);
        }
      }
      result = filtered;
    }

    if(sort == Sort.newest) {
      result.sort((a, b) => a.timeAdded.compareTo(b.timeAdded));
    } else {
      result.sort((a, b) => -1 * a.timeAdded.compareTo(b.timeAdded));
    }
    return result;
  }

  //TODO can this code be made more dry?
  void setSearchTerm(String? searchTerm) {
    if(searchTerm == state.searchTerm) {
      return;
    }
    var filtered = _filterFavorites(state.favorites, searchTerm, state.tags, state.sort);
    emit(state.copyWith(
      filteredFavorites: filtered,
      searchTerm: searchTerm,
    ));
  }

  void setSort(Sort sort) {
    if(sort == state.sort) {
      return;
    }
    var filtered = _filterFavorites(state.favorites, state.searchTerm, state.tags, sort);
    emit(state.copyWith(
      filteredFavorites: filtered,
      sort: sort,
    ));
  }

  void addTag(String tag) {
    if(state.tags.contains(tag)) {
      return;
    }
    var newTags = List<String>.from(state.tags)..add(tag);
    var filtered = _filterFavorites(state.favorites, state.searchTerm, newTags, state.sort);
    emit(state.copyWith(
      filteredFavorites: filtered,
      tags: newTags,
    ));
  }

  void removeTag(String tag) {
    if(!state.tags.contains(tag)) {
      return;
    }
    var newTags = state.tags.where((t) => t != tag).toList();
    var filtered = _filterFavorites(state.favorites, state.searchTerm, newTags, state.sort);
    emit(state.copyWith(
      filteredFavorites: filtered,
      tags: newTags,
    ));
  }

  @override
  Future<void> close() {
    _favoritesCubitSubscription?.cancel();
    return super.close();
  }
}