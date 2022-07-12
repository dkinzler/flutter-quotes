import 'dart:collection';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/quote/provider.dart';

enum LoadingStatus {idle, loading, error}

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
  }) {
    return RandomState(
      status: status ?? this.status,
      quote: quote ?? this.quote,
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
    next();
  }

  void reset() {
    _cache = Queue();
    emit(const RandomState(status: LoadingStatus.idle, quote: null));
  }

  void setQuoteProvider(QuoteProvider provider) {
    quoteProvider = provider;
    _cache = Queue();
  }

  Future<bool> _loadMore() async {
    try {
      var quotes = await quoteProvider.random(10);
      _cache.addAll(quotes);
      return true;
    } catch(e, st) {
      _log.warning('could not load more quotes', e, st);
      return false;
    }
  }

  //TODO maybe trigger loading already if there are <= x elements in cache
  //however need to rework stuff a bit then
  Future<void> next() async {
    if(state.status == LoadingStatus.loading) {
      return;
    }

    emit(const RandomState(status: LoadingStatus.loading, quote: null));
    if(_cache.isEmpty) {
      var success = await _loadMore();
      if(!success) {
        emit(const RandomState(status: LoadingStatus.error, quote: null));
        return;
      }
    }

    var quote = _cache.removeFirst();
    emit(RandomState(status: LoadingStatus.idle, quote: quote));
  }
}