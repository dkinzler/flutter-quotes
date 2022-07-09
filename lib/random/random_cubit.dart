import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/quote/provider.dart';

enum Status {idle, loading, error}

class RandomState extends Equatable {
  final Status status;
  final List<Quote> quotes;
  final int currentQuoteIndex;
  Quote? get currentQuote => currentQuoteIndex < quotes.length ? quotes[currentQuoteIndex] : null;

  const RandomState({
    required this.currentQuoteIndex,
    required this.status,
    required this.quotes
  });

  @override
  List<Object?> get props => [status, quotes, currentQuoteIndex];

  RandomState copyWith({
    Status? status,
    List<Quote>? quotes,
    int? currentQuoteIndex
  }) {
    return RandomState(
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
      currentQuoteIndex: currentQuoteIndex ?? this.currentQuoteIndex,
    );
  }
}

class RandomCubit extends Cubit<RandomState> {
  final _log = Logger('RandomCubit');

  final QuoteProvider quoteProvider;
  final maxImages = 40;

  RandomCubit({
    required this.quoteProvider,
  }) : super(const RandomState(
    status: Status.idle,
    quotes: [],
    currentQuoteIndex: 0,
  )) {
    loadMore();
  }

  Future<bool> loadMore() async {
    if(state.status == Status.loading) {
      return false;
    }
    emit(state.copyWith(status: Status.loading));
    try {
      var quotes = await quoteProvider.random(10);
      //keep at most maxImages images
      //if there are too many remove the oldest ones
      var allQuotes = List<Quote>.from(state.quotes)..addAll(quotes);
      var elementsToRemove = max(0, allQuotes.length - maxImages);
      var newIndex = state.currentQuoteIndex;
      if(elementsToRemove > 0) {
        newIndex -= elementsToRemove;
        allQuotes = allQuotes.sublist(elementsToRemove);
      }
      emit(state.copyWith(
        status: Status.idle,
        quotes: allQuotes,
        currentQuoteIndex: newIndex,
      ));
      return true;
    } catch(e, st) {
      _log.warning('could not load more quotes', e, st);
      emit(state.copyWith(status: Status.error));
      return false;
    }
  }

  //index can be at most state.images.length
  //index==state.images.length will show the loading progress indicator
  void next() {
    var nextIndex = state.currentQuoteIndex + 1;
    if(nextIndex <= state.quotes.length) {
      emit(state.copyWith(
        currentQuoteIndex: nextIndex,
      ));
      if(state.quotes.length - state.currentQuoteIndex < 5) {
        loadMore();
      }
    }
  }

  void prev() {
    var nextIndex = state.currentQuoteIndex - 1;
    if(nextIndex >= 0) {
      emit(state.copyWith(
        currentQuoteIndex: nextIndex,
      ));
    }
  }
}