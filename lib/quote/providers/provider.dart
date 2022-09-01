import 'package:flutter_quotes/quote/providers/mock/apiclient.dart';
import 'package:flutter_quotes/quote/providers/quotable/apiclient.dart';
import 'package:flutter_quotes/quote/model/quote.dart';

/*
Interface for loading random quotes/searching for quotes.
Any class implementing this interface can be used as the source of quotes for the app.

There are currently 2 implementations of QuoteProvider:
- an api client for the online quote API api.quotable.io
- a mock API that returns random quotes from a fixed list of 50 quotes

To support another quote API, create an api client class that implements this interface, 
add it to the QuoteProviderType enum and update QuoteProviderFactory below.
*/
abstract class QuoteProvider {
  Future<List<Quote>> random(int count);

  //the query cursor object is used to implement pagination
  //we can pass a query cursor, obtained from the search result of a previous call to search,
  //to load the next page of results
  Future<SearchResult> search(String query, {Object? queryCursor});
}

class SearchResult {
  final List<Quote> quotes;
  final int? totalNumberOfResults;

  //a query cursor object
  //if non-null and passed to the search() method of QuoteProvider, the next page of results
  //should be returned
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
