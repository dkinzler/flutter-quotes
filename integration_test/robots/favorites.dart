import 'package:flutter/material.dart';
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/favorites/ui/buttons.dart';
import 'package:flutter_quotes/favorites/ui/favorites_screen.dart';
import 'package:flutter_quotes/favorites/ui/filter_bar.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/widgets/quote.dart';
import 'package:flutter_test/flutter_test.dart';
import 'robot.dart';

class FavoritesRobot extends Robot {
  FavoritesRobot({
    required super.tester,
    super.testName,
    super.actionDelay,
    super.binding,
  });

  Future<void> enterFilterTerm(String text) async {
    await enterText(AppKey.favoritesFilterTextField, text);
    //pump some frames because filter bloc takes some time to run in the background
    for (int i = 0; i < 10; i++) {
      await tester.pumpAndSettle();
    }
  }

  Future<void> clearFilterTerm() => enterFilterTerm('');

  Future<void> changeSortOrderToNewest() => _changeSortOrder(SortOrder.newest);

  Future<void> changeSortOrderToOldest() => _changeSortOrder(SortOrder.oldest);

  Future<void> _changeSortOrder(SortOrder sortOrder) async {
    await tap(AppKey.favoritesSortButton);
    if (sortOrder == SortOrder.newest) {
      await tap(AppKey.favoritesSortPopupNewestButton);
    } else {
      await tap(AppKey.favoritesSortPopupOldestButton);
    }
  }

  Future<void> verifyFavoritesAreShown({int? count}) async {
    expect(
        find.descendant(
          of: find.byType(FavoritesScreen),
          matching: find.byType(QuoteCard),
        ),
        count != null ? findsNWidgets(count) : findsWidgets);
  }

  Future<void> verifyNoFavoritesAreShown() async {
    expect(
        find.descendant(
          of: find.byType(FavoritesScreen),
          matching: find.byType(QuoteCard),
        ),
        findsNothing);
  }

  Future<void> tapDeleteFavoriteButton([int? index]) =>
      tap(DeleteFavoriteButton, matchAtIndex: index);

  Future<void> openAddFilterTagsDialog() =>
      tap(AppKey.favoritesFilterAddTagsButton);

  Future<void> verifyAddFilterTagsDialogIsShown() =>
      verifyWidgetIsShown(AppKey.favoritesFilterAddTagsDialog);

  Future<void> addFilterTag([int? index]) async {
    await tap(
      find.descendant(
        of: find.byType(FilterAddTagsDialog),
        matching: find.byType(FilterChip),
      ),
      matchAtIndex: index ?? 0,
    );
  }

  Future<void> closeAddFilterTagsDialog() =>
      tap(AppKey.favoritesFilterCloseAddTagsDialogButton);
}
