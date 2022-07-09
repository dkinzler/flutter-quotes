import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/quote/provider.dart';
import 'package:logging/logging.dart';

//TODO can we do this better with multiple subclases of SearchState
//e.g. right now there will be a lot of null checks

enum SearchStatus {empty, inProgress, success, error}

class SearchState extends Equatable {
  final SearchStatus status;

  final String? query;
  final List<Quote>? quotes;
  final Object? queryCursor;

  bool get canLoadMore => queryCursor != null;
  bool get hasResults => quotes != null;

  const SearchState({
    required this.status,
    this.query,
    this.quotes,
    this.queryCursor,
  });

  const SearchState.empty() : 
    status = SearchStatus.empty,
    query = null,
    quotes = null,
    queryCursor = null;

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

  SearchCubit({required this.quoteProvider}) : super(const SearchState.empty());

  //if no query is provided, search for state.query again
  Future<bool> search({String? query}) async {
    query ??= state.query;
    if(query == null || query.isEmpty) {
      return false;
    }
    if(state.status == SearchStatus.inProgress) {
      return false;
    }
    emit(const SearchState(status: SearchStatus.inProgress));
    try {
      var result = await quoteProvider.search(query);
      emit(SearchState(
        status: SearchStatus.success,
        query: query,
        quotes: result.quotes,
        queryCursor: result.queryCursor,
      ));
      return true;
    } catch(e) {
      _log.warning('search failed', e);
      emit(const SearchState(status: SearchStatus.error));
      return false;
    }
  }

  Future<bool> loadMoreResults() async {
    if(state.status == SearchStatus.inProgress) {
      return false;
    }
    if(state.query == null || !state.hasResults) {
      return false;
    }
    emit(state.copyWith(status: SearchStatus.inProgress));
    try {
      var result = await quoteProvider.search(state.query!, queryCursor: state.queryCursor);
      //TODO this ?? is akward, see note above about different states
      var newQuotes = List<Quote>.from(state.quotes ?? [])..addAll(result.quotes);
      emit(state.copyWith(
        status: SearchStatus.success,
        quotes: newQuotes,
        queryCursor: result.queryCursor,
      ));
      return true;
    } catch(e) {
      _log.warning('could not load more search results', e);
      emit(state.copyWith(status: SearchStatus.error));
      return false;
    }
  }
}