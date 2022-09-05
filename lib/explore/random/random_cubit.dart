import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/quote/repository/repository.dart';
import 'package:logging/logging.dart';
import 'package:flutter_quotes/quote/model/quote.dart';

enum LoadingStatus { idle, loading, error }

class RandomState extends Equatable {
  final LoadingStatus status;
  final List<Quote> quotes;

  const RandomState({required this.status, this.quotes = const []});

  @override
  List<Object?> get props => [status, quotes];

  RandomState copyWith({
    LoadingStatus? status,
    List<Quote>? quotes,
  }) {
    return RandomState(
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
    );
  }
}

class RandomCubit extends Cubit<RandomState> {
  final _log = Logger('RandomCubit');

  final QuoteRepository _quoteRepository;

  RandomCubit({
    required QuoteRepository quoteRepository,
  })  : _quoteRepository = quoteRepository,
        super(const RandomState(
          status: LoadingStatus.idle,
        ));

  void reset() {
    emit(const RandomState(status: LoadingStatus.idle));
  }

  Future<void> loadQuotes(int count) async {
    //don't allow concurrent invocations of this method
    if (state.status == LoadingStatus.loading) {
      return;
    }
    emit(state.copyWith(status: LoadingStatus.loading));
    try {
      var quotes = await _quoteRepository.random(count);
      emit(state.copyWith(status: LoadingStatus.idle, quotes: quotes));
    } catch (e, st) {
      _log.warning('could not load more quotes', e, st);
      emit(state.copyWith(status: LoadingStatus.error));
    }
  }
}
