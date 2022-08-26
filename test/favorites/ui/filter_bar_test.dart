import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/bloc/bloc.dart';
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/favorites/ui/filter_bar.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/quote/quote.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../widget_test_helpers.dart';

void main() {
  group('FilterBar', () {
    late Widget widget;
    late FavoritesCubit favoritesCubit;
    late FilteredFavoritesBloc filteredFavoritesBloc;

    setUp(() async {
      favoritesCubit =
          FavoritesCubit(storageBuilder: FavoritesCubit.mockStorageBuilder);
      favoritesCubit.init('testUser');
      filteredFavoritesBloc = FilteredFavoritesBloc(
          favoritesCubit: favoritesCubit, debounceTime: null);
      //we insert the providers above MaterialApp so that they can also be found from any dialogs
      widget = MultiBlocProvider(
        providers: [
          BlocProvider.value(value: favoritesCubit),
          BlocProvider.value(value: filteredFavoritesBloc),
        ],
        child: buildWidget(const FilterBar()),
      );
    });

    testWidgets(
      'FilterBar updates FilterBloc when search text changes',
      (WidgetTester tester) async {
        await tester.pumpWidget(widget);

        expect(find.byType(FilterBar), findsOneWidget);

        await tester.enterText(
            find.byKey(const ValueKey(AppKey.favoritesFilterTextField)),
            'test');
        await tester.pumpAndSettle();
        //need to introduce an artifical delay for bloc to update it's state
        await waitForBloc(tester);

        //check that filter term in the text field was send to favorites bloc
        expect(filteredFavoritesBloc.state.filters.searchTerm, 'test');
      },
    );

    testWidgets(
      'FilterBar updates FilterBloc when sort order changes',
      (WidgetTester tester) async {
        await tester.pumpWidget(widget);

        //sort order should initially be by newest
        expect(filteredFavoritesBloc.state.sortOrder, SortOrder.newest);

        await tester
            .tap(find.byKey(const ValueKey(AppKey.favoritesSortButton)));
        //popupmenu should open
        await tester.pumpAndSettle();
        await tester.tap(
            find.byKey(const ValueKey(AppKey.favoritesSortPopupOldestButton)));
        await tester.pumpAndSettle();
        //need to introduce an artifical delay for bloc to update it's state
        await waitForBloc(tester);

        //check that filter term in the text field was send to favorites bloc
        expect(filteredFavoritesBloc.state.sortOrder, SortOrder.oldest);
      },
    );

    testWidgets(
      'FilterBar shows chips for filter tags',
      (WidgetTester tester) async {
        await tester.pumpWidget(widget);

        //button to add a tag should be shown
        expect(find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsButton)),
            findsOneWidget);

        filteredFavoritesBloc.emit(filteredFavoritesBloc.state.copyWith(
          filters: const Filters(tags: ['testTag', 'anotherTag']),
        ));
        await tester.pumpAndSettle();

        //button to add a tag should be shown
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

        //set favorites to have some tags to select
        favoritesCubit.emit(FavoritesState(
          status: LoadingStatus.loaded,
          favorites: [
            Favorite(
                quote: const Quote(
                  text: 'xyz',
                  author: 'abc',
                  source: 'test',
                  tags: ['tag1', 'tag2'],
                ),
                timeAdded: DateTime(2022)),
            Favorite(
                quote: const Quote(
                  text: 'xyz',
                  author: 'abc',
                  source: 'test',
                  tags: ['tag3', 'tag4'],
                ),
                timeAdded: DateTime(2022)),
          ],
        ));

        //tap button to add tag to open the dialog
        await tester.tap(
            find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsButton)));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsDialog)),
            findsOneWidget);

        //tags should be shown in dialog
        expect(find.text('tag1'), findsOneWidget);
        expect(find.text('tag2'), findsOneWidget);
        expect(find.text('tag3'), findsOneWidget);
        expect(find.text('tag4'), findsOneWidget);

        //select and unselect some tags
        Finder tagFinder(String tag) {
          return find.ancestor(
              of: find.descendant(
                  of: find.byKey(
                      const ValueKey(AppKey.favoritesFilterAddTagsDialog)),
                  matching: find.text(tag)),
              matching: find.byType(FilterChip));
        }

        //after every select/unselect we need to wait for the bloc to update and the dialog to rebuild because of the bloc state change
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

        //close the dialog
        await tester.tap(find.byKey(
            const ValueKey(AppKey.favoritesFilterCloseAddTagsDialogButton)));
        await tester.pumpAndSettle();

        //selected tags should be tag2 and tag3, and the should be shown in the filter bar
        expect(filteredFavoritesBloc.state.filters.tags, ['tag2', 'tag3']);
        expect(find.text('tag1'), findsNothing);
        expect(find.text('tag2'), findsOneWidget);
        expect(find.text('tag3'), findsOneWidget);
        expect(find.text('tag4'), findsNothing);
        expect(find.byKey(const ValueKey(AppKey.favoritesFilterAddTagsButton)),
            findsOneWidget);

        //tap on delete icon of tag2 to delete it
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
