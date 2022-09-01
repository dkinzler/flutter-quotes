import 'package:flutter_quotes/quote/providers/provider.dart';
import 'package:flutter_quotes/quote/model/quote.dart';

/*
QuoteRepository acts as an intermediary between the quote providers (e.g. an API client for some quote api) and the application/UI-level blocs and cubits.
It uses a single quote provider to search for quotes/get random quotes.
In contrast to directly using an instance of QuoteProvider in e.g. SearchCubit, we can change the quote provider without having to touch SearachCubit at all,
because it will always use the same QuoteRepository. 

QuoteRepository could be used to implement more advanced functionality. We could e.g. use multiple quote providers to answer queries, cache results, etc.
*/
class QuoteRepository {
  QuoteProviderType _quoteProviderType;
  late QuoteProvider _quoteProvider;

  QuoteRepository(
      {QuoteProviderType quoteProviderType = QuoteProviderType.mock})
      : _quoteProviderType = quoteProviderType {
    _quoteProvider =
        QuoteProviderFactory.buildQuoteProvider(_quoteProviderType);
  }

  void changeProvider(QuoteProviderType providerType) {
    if (providerType != _quoteProviderType) {
      _quoteProviderType = providerType;
      _quoteProvider = QuoteProviderFactory.buildQuoteProvider(providerType);
    }
  }

  Future<List<Quote>> random(int count) => _quoteProvider.random(count);

  Future<SearchResult> search(String query, {Object? queryCursor}) =>
      _quoteProvider.search(query, queryCursor: queryCursor);
}
