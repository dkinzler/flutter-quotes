import 'dart:math';

import 'package:flutter_quotes/favorites/ui/buttons.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/widgets/quote.dart';
import 'package:flutter_test/flutter_test.dart';
import 'robot.dart';

class SearchRobot extends Robot {
  SearchRobot({
    required super.tester,
    super.testName,
    super.actionDelay,
    super.binding,
  });

  Future<void> enterSearchTerm(String text) =>
      enterText(AppKey.searchBarTextField, text);

  Future<void> tapSearchButton() => tap(AppKey.searchBarSearchButton);

  Future<void> verifyErrorIsShown() =>
      verifyWidgetIsShown(AppKey.searchErrorRetryWidget);

  Future<void> verifySearchResultsAreShown() async {
    expect(find.byType(QuoteCard), findsWidgets);
  }

  Future<void> tapFavoriteQuoteButton() => tap(FavoriteButton);

  Future<void> scrollDown() => scrollUntilVisible(AppKey.searchLoadMoreButton);

  Future<void> tapLoadMoreButton() => tap(AppKey.searchLoadMoreButton);
}
