import 'package:flutter/widgets.dart';
import 'package:flutter_quotes/favorites/ui/buttons.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/search/search_results.dart';
import 'package:flutter_quotes/search/search_screen.dart';
import 'package:flutter_quotes/search/sliver_search_results.dart';
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

  Future<void> tapSearchButton() =>
      tap(AppKey.searchBarSearchButton, ensureVisible: false);

  Future<void> verifyErrorIsShown() =>
      verifyWidgetIsShown(AppKey.searchErrorRetryWidget);

  Future<void> verifySearchResultsAreShown() async {
    expect(find.byType(QuoteCard), findsWidgets);
  }

  Future<void> tapFavoriteQuoteButton([int? index]) => tap(
        FavoriteButton,
        matchAtIndex: index,
      );

  Future<void> scrollDown() async {
    Finder scrollableFinder;
    //we use different widgets for different layouts (mobile, tablet, desktop, ...)
    if (isWidgetShown(SearchResultsWidget)) {
      scrollableFinder = find.descendant(
        of: find.byType(SearchResultsWidget),
        matching: find.byType(Scrollable),
      );
    } else {
      scrollableFinder = find.descendant(
        of: find.byType(SearchScreen),
        matching: find.byType(Scrollable),
      );
    }
    return scrollUntilVisible(
      AppKey.searchLoadMoreButton,
      delta: 700,
      scrollableFinder: scrollableFinder,
    );
  }

  Future<void> tapLoadMoreButton() => tap(AppKey.searchLoadMoreButton);
}
