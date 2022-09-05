import 'dart:async';
import 'dart:isolate';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quotes/favorites/filter/filter_state.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/filter/filter_events.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_quotes/favorites/repository/favorites_repository.dart'
    hide Status;

/*
FilteredFavoritesBloc takes care of sorting, searching and filtering a user's favorites.
It listens to FavoritesRepository to get the list of favorites of the user. Whenever the list of favorites changes, they are 
filtered and sorted again.

The favorites can be filtered by:
- a search term contained in the quote text or the quote author
- a list of tags (a favorite matches if it has at least one of the tags)

The filtered results can be sorted:
- from newest to oldest (time being added to favorites)
- oldest to newest

We use a bloc here instead of a cubit, because it allows for more control on how the state changes,
e.g. see the comments below on debouncing events.
Using a bloc, however, does introduce some additional boilerplate code, as can be seen below.
*/

class FilteredFavoritesBloc
    extends Bloc<FilteredFavoritesEvent, FilteredFavoritesState> {
  final FavoritesRepository favoritesRepository;
  final Duration? debounceTime;

  FilteredFavoritesBloc({
    required this.favoritesRepository,
    //debouncing can be turned off e.g. for tests
    this.debounceTime = const Duration(milliseconds: 300),
  }) : super(const FilteredFavoritesState(
          status: Status.loading,
          favorites: [],
          filteredFavorites: [],
        )) {
    on<FavoritesSubscriptionRequested>(_onFavoritesSubscriptionRequested,
        transformer: restartable());
    on<SearchTermChanged>(_onSearchTermChanged, transformer: sequential());
    on<FilterTagAdded>(_onTagAdded, transformer: sequential());
    on<FilterTagRemoved>(_onTagRemoved, transformer: sequential());
    on<SortOrderChanged>(_onSortOrderChanged, transformer: sequential());
    on<RecomputeFavoritesRequested>(
      _onRecomputeRequested,
      /*
      This will process only the latest event and only if enough time has passed since the last event.
      Useful e.g. when a user types in a search term, a SearchTermChanged event will be fired for every additional letter typed.
      In turn every SearchTermChanged event will cause a RecomputeFavoritesRequested event to be added.
      However when the letters are typed in quick succession, we do not want to recompute the list of favorites matching the search term
      for every additional letter that changes.
      */
      transformer: debounceTime != null
          ? (events, mapper) => restartable<RecomputeFavoritesRequested>()
              .call(events.debounceTime(debounceTime!), mapper)
          : restartable(),
    );

    //start listening to changes in FavoritesRepository
    add(const FavoritesSubscriptionRequested());
  }

  void _requestRecompute() {
    add(const RecomputeFavoritesRequested());
  }

  Future<void> _onFavoritesSubscriptionRequested(
    FavoritesSubscriptionRequested event,
    Emitter<FilteredFavoritesState> emit,
  ) async {
    await emit.onEach<Favorites>(
      favoritesRepository.getFavorites(),
      onData: (Favorites favorites) {
        //make sure to change the state first before adding the event to request a recompute
        //otherwise we might run into some weird asynchrouns issues, i.e. the recompute event being processed before the state is changed
        emit(state.copyWith(
            status: Status.fromRepositoryStatus(favorites.status),
            favorites: favorites.favorites));
        if (favorites.status.isLoaded) {
          _requestRecompute();
        }
      },
      //this shouldn't happen
      onError: (_, __) => emit(state.copyWith(status: Status.error)),
    );
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
    } else if (!kIsWeb) {
      final p = ReceivePort();
      await Isolate.spawn(
          _recomputeFilteredFavoritesIsolate,
          _FilterIsolateMessage(
            favorites: state.favorites,
            filters: state.filters,
            sortOrder: state.sortOrder,
            sendPort: p.sendPort,
          ));
      var filteredFavorites = await p.first as List<Favorite>;
      emit(state.copyWith(filteredFavorites: filteredFavorites));
    } else {
      //dart isolates are not available on web
      var filteredFavorites = _recomputeFilteredFavorites(
        state.favorites,
        state.filters,
        state.sortOrder,
      );
      emit(state.copyWith(filteredFavorites: filteredFavorites));
    }
  }

  //reload favorites
  //convenience method so that calling code doesn't have to depend on FavoritesRepository
  Future<void> reload() => favoritesRepository.load();

  @override
  Future<void> close() {
    return super.close();
  }
}

//this function is intended to be passed to Isolate.spawn to be run in a separate isolate
List<Favorite> _recomputeFilteredFavorites(
    List<Favorite> favorites, Filters filters, SortOrder sortOrder) {
  var filteredFavorites = filters.filter(favorites);
  sort(filteredFavorites, sortOrder);
  return filteredFavorites;
}

void _recomputeFilteredFavoritesIsolate(_FilterIsolateMessage message) {
  var filteredFavorites = _recomputeFilteredFavorites(
      message.favorites, message.filters, message.sortOrder);
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
