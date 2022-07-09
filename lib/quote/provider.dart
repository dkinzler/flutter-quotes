import 'package:flutter_sample/quote/quote.dart';

abstract class QuoteProvider {
  Future<List<Quote>> random(int count);  
  Future<SearchResult> search(String query, {Object? queryCursor});
}

class SearchResult {
  final List<Quote> quotes;
  final int? totalNumberOfResults;
  final Object? queryCursor;

  const SearchResult({
    required this.quotes,
    this.totalNumberOfResults,
    this.queryCursor,
  });
}