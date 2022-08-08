import 'package:flutter_sample/quote/mock/apiclient.dart';
import 'package:flutter_sample/quote/quotable/apiclient.dart';
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

//enum of quote providers the app supports
//if you implement and add another quote provider don't forget to add it to the
//QuoteProviderFactory below and update the settings screen
enum QuoteProviderType {
  mock,
  quotable;

  factory QuoteProviderType.fromString(String s) {
    if (s == quotable.name) {
      return quotable;
    } else {
      //return mock even if the given string doesn't match any of the providers
      //alternatively we could also throw an exception if there is no match
      return mock;
    }
  }
}

class QuoteProviderFactory {
  static QuoteProvider buildQuoteProvider(QuoteProviderType type) {
    switch (type) {
      case QuoteProviderType.quotable:
        return QuotableApiClient();
      default:
        return MockQuoteApiClient();
    }
  }
}
