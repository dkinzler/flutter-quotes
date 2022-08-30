import 'dart:collection';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/quote/repository/repository.dart';
import 'package:logging/logging.dart';
import 'package:flutter_quotes/quote/quote.dart';

/*
RandomCubit manages and loads random quotes from a quote provider.
The cubit state consists of the following: 
- a status field indicating the status/result of the latest operation to retrieve quotes from the quote provider
- the current random quote or null if no quote has been loaded yet
*/

/*
loading: an operation to load quotes from the quote provider is currently in progress
error: the latest attempt to load quotes failed
idle: the latest attempt to load quotes succeeded
*/
enum LoadingStatus { idle, loading, error }

class RandomState extends Equatable {
  final LoadingStatus status;
  final Quote? quote;

  const RandomState({required this.status, required this.quote});

  @override
  List<Object?> get props => [status, quote];

  RandomState copyWith({
    LoadingStatus? status,
    Quote? quote,
    //need this because, passing quote=null here won't work
    bool nullQuote = false,
  }) {
    return RandomState(
      status: status ?? this.status,
      quote: nullQuote ? null : quote ?? this.quote,
    );
  }
}

class RandomCubit extends Cubit<RandomState> {
  final _log = Logger('RandomCubit');

  final QuoteRepository _quoteRepository;
  Queue<Quote> _cache = Queue();

  RandomCubit({
    required QuoteRepository quoteRepository,
  })  : _quoteRepository = quoteRepository,
        super(const RandomState(
          status: LoadingStatus.idle,
          quote: null,
        )) {
    init();
  }

  void init() {
    _cache = Queue();
    emit(const RandomState(status: LoadingStatus.idle, quote: null));
    loadMore();
  }

  void reset() {
    _cache = Queue();
    emit(const RandomState(status: LoadingStatus.idle, quote: null));
  }

  Future<void> loadMore() async {
    //don't allow concurrent invocations of this method
    if (state.status == LoadingStatus.loading) {
      return;
    }
    emit(state.copyWith(status: LoadingStatus.loading));
    try {
      var quotes = await _quoteRepository.random(10);
      _cache.addAll(quotes);
      emit(state.copyWith(status: LoadingStatus.idle));
      if (state.quote == null) {
        next();
      }
    } catch (e, st) {
      _log.warning('could not load more quotes', e, st);
      emit(state.copyWith(status: LoadingStatus.error));
    }
  }

  void next() {
    if (_cache.isNotEmpty) {
      var quote = _cache.removeFirst();
      emit(state.copyWith(quote: quote));
      //load more quotes before cache is empty
      if (_cache.length < 2) {
        loadMore();
      }
    } else if (state.quote != null) {
      emit(state.copyWith(nullQuote: true));
      loadMore();
    }
  }
}
