import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_sample/quote/mock/example_quotes.dart';
import 'package:flutter_sample/quote/provider.dart';
import 'package:flutter_sample/quote/quote.dart';

class MockQuoteApiClient implements QuoteProvider {
  @override
  Future<List<Quote>> random(int count) async {
    await Future.delayed(const Duration(seconds: 4));
    return _randomQuotes(count);
  }

  //this will just pick random quotes from the example quote list
  //the same quote may be included multiple times
  List<Quote> _randomQuotes(int count) {
    List<Quote> quotes = [];
    var r = Random();
    for (int i = 0; i < count; i++) {
      var index = r.nextInt(exampleQuotes.length);
      quotes.add(exampleQuotes[index]);
    }
    return quotes;
  }

  @override
  Future<SearchResult> search(String query, {Object? queryCursor}) async {
    if (queryCursor is! MockQueryCursor?) {
      throw Exception(
          'passed invalid query cursor, type: ${queryCursor.runtimeType}');
    }
    var quotes = _randomQuotes(20);
    MockQueryCursor? nextCursor;
    if (queryCursor == null) {
      nextCursor = const MockQueryCursor(nextPage: 2, pageCount: 20);
    } else if (queryCursor.nextPage < 20) {
      nextCursor = MockQueryCursor(
        nextPage: queryCursor.nextPage + 1,
        pageCount: 20,
      );
    }
    return SearchResult(
      quotes: quotes,
      queryCursor: nextCursor,
      totalNumberOfResults: 20 * 20,
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
