import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_quotes/quote/model/quote.dart';
import 'package:flutter_quotes/quote/providers/provider.dart';
import 'package:flutter_quotes/quote/providers/quotable/model.dart';

//API client for the Quotable API.
class QuotableApiClient implements QuoteProvider {
  static final _baseUri = Uri(
    scheme: 'https',
    host: 'api.quotable.io',
  );

  final http.Client _httpClient;

  QuotableApiClient() : _httpClient = http.Client();

  @override
  Future<List<Quote>> random(int count) async {
    if (count > 20) {
      count = 20;
    }
    try {
      List<Quote> results = [];
      for (int i = 0; i < count; i++) {
        results.add(await _singleRandom());
      }
      return results;
    } on QuotableApiError {
      rethrow;
    } catch (e) {
      throw QuotableApiError(
          message: 'could not get random quotes', exception: e);
    }
  }

  Future<Quote> _singleRandom() async {
    try {
      var resp = await _httpClient.get(_baseUri.replace(
        path: 'random',
      ));
      if (resp.statusCode != 200) {
        throw _parseApiError(resp);
      }
      return _parseSingleResult(resp.body);
    } on QuotableApiError {
      rethrow;
    } catch (e) {
      throw QuotableApiError(message: 'http request failed', exception: e);
    }
  }

  Quote _parseSingleResult(String responseBody) {
    try {
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      return QuotableQuote.fromMap(jsonResponse).toQuote();
    } catch (e) {
      throw QuotableApiError(
          message: 'could not parse search result', exception: e);
    }
  }

  @override
  Future<SearchResult> search(String query, {Object? queryCursor}) async {
    try {
      if (queryCursor is! QuotableQueryCursor?) {
        throw QuotableApiError(
            message:
                'passed invalid query cursor, type: ${queryCursor.runtimeType}');
      }
      var resp = await _httpClient.get(_baseUri.replace(
        path: 'search/quotes',
        queryParameters: {
          'query': query,
          if (queryCursor != null) 'page': queryCursor.nextPage.toString(),
        },
      ));
      if (resp.statusCode != 200) {
        throw _parseApiError(resp);
      }
      return _parseSearchResult(resp.body);
    } on QuotableApiError {
      rethrow;
    } catch (e) {
      throw QuotableApiError(message: 'http request failed', exception: e);
    }
  }

  SearchResult _parseSearchResult(String responseBody) {
    try {
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      int page = jsonResponse['page'];
      int pageCount = jsonResponse['totalPages'];
      int totalResultCount = jsonResponse['totalCount'];
      var nextPage = page + 1;
      var cursor = nextPage <= pageCount
          ? QuotableQueryCursor(nextPage: nextPage, pageCount: pageCount)
          : null;

      List<dynamic> results = jsonResponse['results'];
      var quotes = results
          .map<Quote>((e) => QuotableQuote.fromMap(e).toQuote())
          .toList();
      return SearchResult(
        quotes: quotes,
        queryCursor: cursor,
        totalNumberOfResults: totalResultCount,
      );
    } catch (e) {
      throw QuotableApiError(
          message: 'could not parse search result', exception: e);
    }
  }

  QuotableApiError _parseApiError(http.Response resp) {
    return QuotableApiError(
      message: 'unexpected status code',
      httpStatusCode: resp.statusCode,
      httpResponseBody: resp.body,
    );
  }
}

class QuotableQueryCursor extends Equatable {
  final int nextPage;
  final int pageCount;

  const QuotableQueryCursor({
    required this.nextPage,
    required this.pageCount,
  });

  @override
  List<Object?> get props => [nextPage, pageCount];
}

class QuotableApiError extends Equatable implements Exception {
  final String message;

  //response code from http request
  final int? httpStatusCode;
  //http response body
  final String? httpResponseBody;

  final Object? exception;

  const QuotableApiError({
    required this.message,
    this.httpStatusCode,
    this.httpResponseBody,
    this.exception,
  });

  @override
  List<Object?> get props => [
        message,
        httpStatusCode,
        httpResponseBody,
        exception,
      ];

  @override
  String toString() {
    var properties = <String>[
      'message: $message',
      if (httpStatusCode != null) 'httpStatusCode: $httpStatusCode',
      if (httpResponseBody != null) 'httpResponseBody: $httpResponseBody',
      if (exception != null) 'exception: $exception',
    ];
    return 'QuotableApiError {${properties.join(', ')}}';
  }
}
