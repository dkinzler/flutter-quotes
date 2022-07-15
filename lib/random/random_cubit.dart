import 'dart:collection';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/quote/provider.dart';

enum LoadingStatus {idle, loading, error}

//this needs to be tested

class RandomState extends Equatable {
  final LoadingStatus status;
  final Quote? quote;

  const RandomState({
    required this.status,
    required this.quote
  });

  @override
  List<Object?> get props => [status, quote];

  RandomState copyWith({
    LoadingStatus? status,
    Quote? quote,
    //need this because we passing quote=null here won't work
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

  QuoteProvider quoteProvider;
  Queue<Quote> _cache = Queue();

  RandomCubit({
    required this.quoteProvider,
  }) : super(const RandomState(
    status: LoadingStatus.idle,
    quote: null,
  )) {
    loadMore();
  }

  void reset() {
    _cache = Queue();
    emit(const RandomState(status: LoadingStatus.idle, quote: null));
  }

  void setQuoteProvider(QuoteProvider provider) {
    quoteProvider = provider;
    _cache = Queue();
  }

  Future<void> loadMore() async {
    if(state.status == LoadingStatus.loading) {
      return;
    }

    emit(state.copyWith(status: LoadingStatus.loading));
    try {
      var quotes = await quoteProvider.random(10);
      _cache.addAll(quotes);
      emit(state.copyWith(status: LoadingStatus.idle));
      if(state.quote == null) {
        next();
      }
    } catch(e, st) {
      _log.warning('could not load more quotes', e, st);
      emit(state.copyWith(status: LoadingStatus.error));
    }
  }

  void next() {
    if(_cache.isNotEmpty) {
      var quote = _cache.removeFirst();
      emit(state.copyWith(quote: quote));
      if(_cache.length < 4) {
        loadMore();
      }
    } else if(state.quote != null) {
      emit(state.copyWith(nullQuote: true));
      loadMore();
    }
  }
}