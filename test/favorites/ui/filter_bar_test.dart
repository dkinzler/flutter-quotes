import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/repository/favorites_repository.dart';
import 'package:flutter_quotes/favorites/repository/storage/favorites_storage.dart';
import 'package:flutter_quotes/favorites/widgets/filter_bar.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/quote/model/quote.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../widget_test_helpers.dart';

void main() {
  var exampleFavorites = [
    Favorite(
      quote: const Quote(
        text: 'quote1',
        author: 'abc',
        source: 'test',
        tags: ['tag1', 'tag2'],
      ),
      timeAdded: DateTime(2022),
    ),
    Favorite(
      quote: const Quote(
        text: 'quote2',
        author: 'abc',
        source: 'test',
        tags: ['tag3', 'tag4'],
      ),
      timeAdded: DateTime(2022),
    ),
  ];

  group('FilterBar', () {
    late Widget widget;
    late FavoritesRepository favoritesRepository;
    late FilteredFavoritesBloc filteredFavoritesBloc;

    setUp(() async {
      favoritesRepository =
          FavoritesRepository(storageType: FavoritesStorageType.mock);
      await favoritesRepository.init('testUserId');
      filteredFavoritesBloc = FilteredFavoritesBloc(
          favoritesRepository: favoritesRepository, debounceTime: null);
      // we insert the providers above MaterialApp so that they can also be found from any dialogs
      widget = MultiBlocProvider(
        providers: [
          BlocProvider.value(value: filteredFavoritesBloc),
        ],
        child: buildWidget(const FilterBar()),
      );
    });

    testWidgets(
      'FilterBar updates FilterBloc when search text changes',
      (WidgetTester tester) async {
        await tester.pumpWidget(widget);
        // wait for bloc to process initial events
        await waitForBloc(tester, duration: const Duration(milliseconds: 100));

        expect(find.byType(FilterBar), findsOneWidget);

        await tester.enterText(
            find.byKey(const ValueKey(AppKey.favoritesFilterTextField)),
            'test');
        await tester.pumpAndSettle();
        // need to introduce an artifical delay for bloc to update it's state
        await waitForBloc(tester);

        // check that filter term in the text field was send to favorites bloc
        expect(filteredFavoritesBloc.state.filters.searchTerm, 'test');
      },
    );

    testWidgets(
      'FilterBar updates FilterBloc when sort order changes',
      (WidgetTester tester) async {
        await tester.pumpWidget(widget);
        // wait for bloc to process initial events
        await waitForBloc(tester, duration: const Duration(milliseconds: 100));

        // sort order should initially be by newest
        expect(filteredFavoritesBloc.state.sortOrder, SortOrder.newest);

        await tester
            .tap(find.byKey(const ValueKey(AppKey.favoritesSortButton)));
        // popupmenu should open
        await tester.pumpAndSettle();
        await tester.tap(
            find.byKey(const ValueKey(AppKey.favoritesSortPopupOldestButton)));
        await tester.pumpAndSettle();
        // need to introduce an artifical delay for bloc to update it's state
        await waitForBloc(tester);

        // check that filter term in the text field was send to favorites bloc
        expect(filteredFavoritesBloc.state.sortOrder, SortOrder.oldest);
      },
    );

    testWidgets(
      'FilterBar shows chips for filter tags',
      (WidgetTester tester) async {
        await tester.pumpWidget(widget);
        // wait for bloc to process initial events
        await waitForBloc(tester, duration: const Duration(milliseconds: 100));

        // button to add a tag should be shown
        expect(find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsButton)),
            findsOneWidget);

        filteredFavoritesBloc.emit(filteredFavoritesBloc.state.copyWith(
          filters: const Filters(tags: ['testTag', 'anotherTag']),
        ));
        await tester.pumpAndSettle();

        // button to add a tag should be shown
        expect(find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsButton)),
            findsOneWidget);
        expect(find.text('testTag'), findsOneWidget);
        expect(find.text('anotherTag'), findsOneWidget);
      },
    );

    testWidgets(
      'Adding and removing tags works',
      (WidgetTester tester) async {
        await tester.pumpWidget(widget);
        // wait for bloc to process initial events
        await waitForBloc(tester, duration: const Duration(milliseconds: 100));

        // set favorites to have some tags to select
        for (final favorite in exampleFavorites) {
          await favoritesRepository.add(favorite);
        }
        await waitForBloc(tester, duration: const Duration(milliseconds: 100));

        // tap button to add tag to open the dialog
        await tester.tap(
            find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsButton)));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsDialog)),
            findsOneWidget);

        // tags should be shown in dialog
        expect(find.text('tag1'), findsOneWidget);
        expect(find.text('tag2'), findsOneWidget);
        expect(find.text('tag3'), findsOneWidget);
        expect(find.text('tag4'), findsOneWidget);

        // select and unselect some tags
        Finder tagFinder(String tag) {
          return find.ancestor(
              of: find.descendant(
                  of: find.byKey(
                      const ValueKey(AppKey.favoritesFilterAddTagsDialog)),
                  matching: find.text(tag)),
              matching: find.byType(FilterChip));
        }

        // after every select/unselect we need to wait for the bloc to update and the dialog to rebuild because of the bloc state change
        await tester.tap(tagFinder('tag1'));
        await tester.pumpAndSettle();
        await waitForBloc(tester);
        await tester.pumpAndSettle();
        await tester.tap(tagFinder('tag2'));
        await tester.pumpAndSettle();
        await waitForBloc(tester);
        await tester.pumpAndSettle();
        await tester.tap(tagFinder('tag1'));
        await tester.pumpAndSettle();
        await waitForBloc(tester);
        await tester.pumpAndSettle();
        await tester.tap(tagFinder('tag3'));
        await tester.pumpAndSettle();
        await waitForBloc(tester);
        await tester.pumpAndSettle();

        // close the dialog
        await tester.tap(find.byKey(
            const ValueKey(AppKey.favoritesFilterCloseAddTagsDialogButton)));
        await tester.pumpAndSettle();

        // selected tags should be tag2 and tag3, and the should be shown in the filter bar
        expect(filteredFavoritesBloc.state.filters.tags, ['tag2', 'tag3']);
        expect(find.text('tag1'), findsNothing);
        expect(find.text('tag2'), findsOneWidget);
        expect(find.text('tag3'), findsOneWidget);
        expect(find.text('tag4'), findsNothing);
        expect(find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsButton)),
            findsOneWidget);

        // tap on delete icon of tag2 to delete it
        await tester.tap(find.descendant(
            of: find.ancestor(
                of: find.text('tag2'), matching: find.byType(InputChip)),
            matching: find.byIcon(Icons.cancel)));
        await tester.pumpAndSettle();
        await waitForBloc(tester);
        await tester.pumpAndSettle();

        expect(filteredFavoritesBloc.state.filters.tags, ['tag3']);
        expect(find.text('tag2'), findsNothing);
        expect(find.text('tag3'), findsOneWidget);
        expect(find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsButton)),
            findsOneWidget);
      },
    );
  });
}

Future<void> waitForBloc(WidgetTester tester,
    {Duration duration = Duration.zero}) {
  return tester.runAsync(() => Future.delayed(duration));
}
