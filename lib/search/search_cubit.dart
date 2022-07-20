import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/quote/provider.dart';
import 'package:logging/logging.dart';

/*
SearchCubit can be used to search for quotes using a quote provider.
The state of the cubit consists of the following:
- the current search status
    * inProgress: if a search operation is currently running, can be an initial search or loading more results for a previous search
    * error: the latest search opeartion failed
    * idle: the latest search operation succeeded or no search has been run yet
- the current search query string, empty string if no search has been performed yet
- the search result for the current query, i.e. a list of quotes, or null if no search has been performed
- a query cursor that can be handed to the quote provider to load more results for the given query
  is null if no query has been performed yet or there are no more results
*/

enum SearchStatus {idle, inProgress, error}

class SearchState extends Equatable {
  final SearchStatus status;

  final String query;
  final List<Quote>? quotes;
  final Object? queryCursor;

  bool get canLoadMore => queryCursor != null;
  bool get hasResults => quotes != null;
  bool get hasQuery => query.isNotEmpty;

  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.quotes,
    this.queryCursor,
  });

  @override
  List<Object?> get props => [status, query, quotes, queryCursor];

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Quote>? quotes,
    Object? queryCursor,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      quotes: quotes ?? this.quotes,
      queryCursor: queryCursor ?? this.queryCursor,
    );
  }
}

class SearchCubit extends Cubit<SearchState> {
  final _log  = Logger('SearchCubit');

  QuoteProvider quoteProvider;

  SearchCubit({required this.quoteProvider}) 
    : super(const SearchState());

  //if no query is provided, search for state.query again (if non-null)
  Future<bool> search({String? query}) async {
    query ??= state.query;
    if(query.isEmpty || state.status == SearchStatus.inProgress) {
      return false;
    }
    emit(SearchState(
      status: SearchStatus.inProgress,
      query: query,
    ));
    try {
      var result = await quoteProvider.search(query);
      emit(SearchState(
        status: SearchStatus.idle,
        query: query,
        quotes: result.quotes,
        queryCursor: result.queryCursor,
      ));
      return true;
    } catch(e) {
      emit(SearchState(
        status: SearchStatus.error,
        query: query,
      ));
      _log.warning('search failed', e);
      return false;
    }
  }

  Future<bool> loadMoreResults() async {
    if(state.status == SearchStatus.inProgress) {
      return false;
    }
    if(state.query.isEmpty || !state.hasResults) {
      return false;
    }
    emit(state.copyWith(status: SearchStatus.inProgress));
    try {
      var result = await quoteProvider.search(
        state.query,
        queryCursor: state.queryCursor,
      );
      var newQuotes = List<Quote>.from(state.quotes ?? [])..addAll(result.quotes);
      emit(state.copyWith(
        status: SearchStatus.idle,
        quotes: newQuotes,
        queryCursor: result.queryCursor,
      ));
      return true;
    } catch(e) {
      emit(state.copyWith(status: SearchStatus.error));
      _log.warning('could not load more search results', e);
      return false;
    }
  }
}