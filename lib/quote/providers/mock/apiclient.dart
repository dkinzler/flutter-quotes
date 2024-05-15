import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/quote/providers/mock/example_quotes.dart';
import 'package:flutter_quotes/quote/providers/provider.dart';
import 'package:flutter_quotes/quote/model/quote.dart';

class MockQuoteApiClient implements QuoteProvider {
  // an artifical delay that is applied to the query methods
  // this makes it easy to simulate slow api requests and observe what is going
  // in the UI while an api request is in progress
  Duration delay;

  MockQuoteApiClient({
    this.delay = const Duration(seconds: 1),
  });

  void setDelay(Duration delay) {
    this.delay = delay;
  }

  Future<void> _applyDelay() async {
    if (delay.inMicroseconds > 0) {
      await Future.delayed(delay);
    }
  }

  @override
  Future<List<Quote>> random(int count) async {
    await _applyDelay();
    return _randomQuotes(count);
  }

  // pick random quotes from the example quote list
  // the same quote may be included multiple times
  List<Quote> _randomQuotes(int count) {
    List<Quote> quotes = [];
    var r = Random();
    for (int i = 0; i < count; i++) {
      var index = r.nextInt(exampleQuotes.length);
      quotes.add(exampleQuotes[index]);
    }
    return quotes;
  }

  // ignore the query term and return a random list of quotes
  @override
  Future<SearchResult> search(String query, {Object? queryCursor}) async {
    if (queryCursor is! MockQueryCursor?) {
      throw Exception(
          'passed invalid query cursor, type: ${queryCursor.runtimeType}');
    }
    await _applyDelay();
    if (query == 'forceError') {
      throw Exception('query failed');
    }
    var quotes = _randomQuotes(20);
    MockQueryCursor? nextCursor;
    if (queryCursor == null) {
      nextCursor = const MockQueryCursor(nextPage: 2, pageCount: 4);
    } else if (queryCursor.nextPage < 4) {
      nextCursor = MockQueryCursor(
        nextPage: queryCursor.nextPage + 1,
        pageCount: 4,
      );
    }
    return SearchResult(
      quotes: quotes,
      queryCursor: nextCursor,
      totalNumberOfResults: 4 * 20,
    );
  }
}

class MockQueryCursor extends Equatable {
  final int nextPage;
  final int pageCount;

  const MockQueryCursor({
    required this.nextPage,
    required this.pageCount,
  });

  @override
  List<Object?> get props => [];
}
