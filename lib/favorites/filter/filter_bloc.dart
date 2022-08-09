import 'dart:async';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_sample/favorites/bloc/favorite.dart';
import 'package:flutter_sample/favorites/filter/filter_events.dart';
import 'package:flutter_sample/favorites/filter/filter_state.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_sample/favorites/bloc/favorites_cubit.dart';

/*
TODO
filtered favorites get recomputed on every change to favorites
even if the favorites page isn't even open
we could avoid this by having a filteredFavorites getter
that returns a future
however we then have the problem of how we apply debouncing
we could e.g. add a ticker to the state where the same instance always gets passed to the next state
when copyWith is called?
*/

/*
FilteredFavoritesBloc takes care of sorting, searching and filtering a user's favorites.
It listens to state changes of FavoritesCubit, whenever the list of favorites changes, they are 
filtered and sorted again.

The favorites can be filtered by:
- a search term contained in the quote text or the quote author
- a list of tags (a favorite matches if it has at least one of the tags)

The filtered results can be sorted:
- from newest to oldest (time being added to favorites)
- oldest to newest

We use a bloc here instead of a cubit, because it allows for more control on how the state changes,
e.g. see the comments below on debouncing events.
*/

class FilteredFavoritesBloc
    extends Bloc<FilteredFavoritesEvent, FilteredFavoritesState> {
  final FavoritesCubit favoritesCubit;
  StreamSubscription? _favoritesCubitSubscription;

  FilteredFavoritesBloc({
    required this.favoritesCubit,
  }) : super(const FilteredFavoritesState(
          favorites: [],
          filteredFavorites: [],
        )) {
    on<FavoritesChanged>(_onFavoritesChanged, transformer: sequential());
    on<SearchTermChanged>(_onSearchTermChanged, transformer: sequential());
    on<FilterTagAdded>(_onTagAdded, transformer: sequential());
    on<FilterTagRemoved>(_onTagRemoved, transformer: sequential());
    on<SortOrderChanged>(_onSortOrderChanged, transformer: sequential());
    on<RecomputeFavoritesRequested>(
      _onRecomputeRequested,
      /*
      This will process the events sequentially but only process events that were added at least the given duration after the last event was processed.
      Useful e.g. when a user types in a search term, a SearchTermChanged event will be fired for every additional letter typed.
      In turn every SearchTermChanged event will cause a RecomputeFavoritesRequested event to be added.
      However when the letters are typed in quick succession, we do not want to recompute the list of favorites matching the search term
      for every additional letter that changes.
      */
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .asyncExpand(mapper),
    );

    //listen to state changes in FavoritesCubit
    _favoritesCubitSubscription =
        favoritesCubit.stream.listen((favoritesState) {
      add(FavoritesChanged(favorites: favoritesCubit.state.favorites));
    });
    //need to fire an event with the current cubit state, since the listener
    //above will only be called for subsequent state changes
    add(FavoritesChanged(favorites: favoritesCubit.state.favorites));
  }

  void _requestRecompute() {
    add(const RecomputeFavoritesRequested());
  }

  void _onFavoritesChanged(
      FavoritesChanged event, Emitter<FilteredFavoritesState> emit) {
    //only process the event if the list of favorites actually changed
    if (state.favorites != event.favorites) {
      emit(state.copyWith(favorites: event.favorites));
      _requestRecompute();
    }
  }

  void _onSearchTermChanged(
      SearchTermChanged event, Emitter<FilteredFavoritesState> emit) {
    if (state.filters.searchTerm != event.searchTerm) {
      emit(state.copyWith(
          filters: state.filters.copyWith(searchTerm: event.searchTerm)));
      _requestRecompute();
    }
  }

  void _onTagAdded(FilterTagAdded event, Emitter<FilteredFavoritesState> emit) {
    var newFilters = state.filters.copyWithTag(event.tag);
    if (newFilters != state.filters) {
      emit(state.copyWith(filters: newFilters));
      _requestRecompute();
    }
  }

  void _onTagRemoved(
      FilterTagRemoved event, Emitter<FilteredFavoritesState> emit) {
    var newFilters = state.filters.copyWithTagRemoved(event.tag);
    if (newFilters != state.filters) {
      emit(state.copyWith(filters: newFilters));
      _requestRecompute();
    }
  }

  void _onSortOrderChanged(
      SortOrderChanged event, Emitter<FilteredFavoritesState> emit) {
    if (state.sortOrder != event.sortOrder) {
      emit(state.copyWith(sortOrder: event.sortOrder));
      _requestRecompute();
    }
  }

  Future<void> _onRecomputeRequested(RecomputeFavoritesRequested event,
      Emitter<FilteredFavoritesState> emit) async {
    if (state.filters.isEmpty) {
      var sortedFavorites = List<Favorite>.from(state.favorites);
      sort(sortedFavorites, state.sortOrder);
      emit(state.copyWith(filteredFavorites: sortedFavorites));
    } else {
      final p = ReceivePort();
      await Isolate.spawn(
          _recomputeFilteredFavorites,
          _FilterIsolateMessage(
            favorites: state.favorites,
            filters: state.filters,
            sortOrder: state.sortOrder,
            sendPort: p.sendPort,
          ));
      var filteredFavorites = await p.first as List<Favorite>;
      emit(state.copyWith(filteredFavorites: filteredFavorites));
    }
  }

  @override
  Future<void> close() {
    _favoritesCubitSubscription?.cancel();
    return super.close();
  }
}

//this function is intended to be passed to Isolate.spawn to be run in a separate isolate
void _recomputeFilteredFavorites(_FilterIsolateMessage message) {
  var favorites = message.favorites;
  var filters = message.filters;
  var sortOrder = message.sortOrder;
  var filteredFavorites = filters.filter(favorites);
  sort(filteredFavorites, sortOrder);
  Isolate.exit(message.sendPort, filteredFavorites);
}

class _FilterIsolateMessage {
  final List<Favorite> favorites;
  final Filters filters;
  final SortOrder sortOrder;
  final SendPort sendPort;

  const _FilterIsolateMessage({
    required this.favorites,
    required this.filters,
    required this.sortOrder,
    required this.sendPort,
  });
}
