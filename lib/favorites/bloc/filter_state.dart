import 'package:equatable/equatable.dart';
import 'package:flutter_sample/favorites/bloc/favorite.dart';

class FilteredFavoritesState extends Equatable {
  //the current list of favorites obtained from FavoritesCubit
  final List<Favorite> favorites;
  //the list of favorites matching the filters below and sorted by sortOrder
  //since bloc events are processed asynchronously, this will not always be immediately consistent with the filters and sort order below
  //however eventually the filters will be applied
  final List<Favorite> filteredFavorites;

  final Filters filters;
  final SortOrder sortOrder;

  const FilteredFavoritesState({
    required this.filteredFavorites,
    required this.favorites,
    this.filters = const Filters(),
    this.sortOrder = SortOrder.newest,
  });

  @override
  List<Object?> get props => [favorites, filteredFavorites, filters, sortOrder];

  FilteredFavoritesState copyWith({
    List<Favorite>? filteredFavorites,
    List<Favorite>? favorites,
    Filters? filters,
    SortOrder? sortOrder,
  }) {
    return FilteredFavoritesState(
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      favorites: favorites ?? this.favorites,
      filters: filters ?? this.filters,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

enum SortOrder {newest, oldest}

void sort(List<Favorite> favorites, SortOrder sortOrder) {
  if(sortOrder == SortOrder.newest) {
    favorites.sort((a, b) => b.timeAdded.compareTo(a.timeAdded));
  } else {
    favorites.sort((a, b) => a.timeAdded.compareTo(b.timeAdded));
  }
}

class Filters extends Equatable {
  final String searchTerm;
  final List<String> tags;

  const Filters({
    this.searchTerm = '',
    this.tags = const[],
  });

  bool get isEmpty => searchTerm.isEmpty && tags.isEmpty;

  @override
  List<Object?> get props => [searchTerm, tags];

  //given a list of favorites return the list of favorites that match 
  //the conditions defined by this object
  List<Favorite> filter(List<Favorite> favorites) {
    return filterBySearchTerm(filterByTags(favorites));
  }

  List<Favorite> filterBySearchTerm(List<Favorite> favorites) {
    if(searchTerm.isEmpty) {
      return favorites;
    }

    List<Favorite> result = [];
    for(final favorite in favorites) {
      if(favorite.quote.text.contains(searchTerm) ||
         favorite.quote.author.contains(searchTerm)
      ) {
        result.add(favorite);
      }
    }
    return result;
  }

  List<Favorite> filterByTags(List<Favorite> favorites) {
    if(tags.isEmpty) {
      return favorites;
    }

    List<Favorite> result = [];
    for(final favorite in favorites) {
      bool contained = false;
      for(final tag in tags) {
        if(favorite.quote.tags.contains(tag)) {
          contained = true;
          break;
        }
      }
      if(contained) {
        result.add(favorite);
      }
    }
    return result;
  }

  Filters copyWith({
    String? searchTerm,
    List<String>? tags,
  }) {
    return Filters(
      searchTerm: searchTerm ?? this.searchTerm,
      tags: tags ?? this.tags,
    );
  }

  Filters copyWithTag(String tag) {
    if(tags.contains(tag)) {
      return this;
    }
    var newTags = List<String>.from(tags)..add(tag);
    return copyWith(tags: newTags);
  }

  Filters copyWithTagRemoved(String tag) {
    if(!tags.contains(tag)) {
      return this;
    }
    var newTags = tags.where((t) => t != tag).toList();
    return copyWith(tags: newTags);
  }
}