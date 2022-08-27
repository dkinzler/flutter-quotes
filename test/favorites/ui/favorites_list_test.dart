import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/bloc/bloc.dart';
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/favorites/ui/actions.dart';
import 'package:flutter_quotes/favorites/ui/buttons.dart';
import 'package:flutter_quotes/favorites/ui/favorites_list.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/quote/quote.dart';
import 'package:flutter_quotes/widgets/quote.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../widget_test_helpers.dart';

/*
These are typical widget tests, that test the interplay between components maintaining state (like a Bloc or Cubit)
and a Widget that changes based on that state.

There are two different things we test here:

* Based on the state of FavoritesCubit/FilteredFavoritesBloc, the FavoritesList widget shows the correct UI.
  E.g. while FavoritesCubit loads the favorites of the user from storage, the UI should show a CircularProgressIndicator.
  If the user has not yet favorited any quotes, show a Text widget with text 'You have not favorited any quotes'.
  If the user has filtered the quotes (e.g. by entering a serach term or selecting a particular tag), only show the qutoes that match. 
  This type of test is typically performed by the following steps:
    * create an instance of FavoritesCubit and FilteredFavoritesBloc
    * build the FavoritesList widget
    * update the state of the cubit/bloc
    * check that FavoritesList updates the ui and shows the correct elements

* When we interact with the FavoritesList widget, the state of FavoritesCubit/FilteredFavoritesBloc is updated correctly.
  E.g. when we press on the button to delete a favorite, we expect FavoritesCubit to update its list of favorites to no longer include the quote.
  This type of test typically takes the following form:
    * create an instance of FavoritesCubit and FilteredFavoritesBloc
    * build the FavoritesListWidget
    * interact with the widget, e.g. by pressing a button
    * check that the state of the cubit/bloc updates correctly
  More examples of this type of test can be found in 'filter_bar_test.dart'.
*/
void main() {
  group('FavoritesList', () {
    late Widget widget;
    late FavoritesCubit favoritesCubit;
    late FilteredFavoritesBloc filteredFavoritesBloc;

    setUp(() async {
      favoritesCubit =
          FavoritesCubit(storageBuilder: FavoritesCubit.mockStorageBuilder);
      await favoritesCubit.init('testUser');
      filteredFavoritesBloc = FilteredFavoritesBloc(
          favoritesCubit: favoritesCubit, debounceTime: null);
      //we insert the providers above MaterialApp so that they can also be found from any dialogs
      widget = MultiBlocProvider(
        providers: [
          BlocProvider.value(value: favoritesCubit),
          BlocProvider.value(value: filteredFavoritesBloc),
        ],
        child: buildWidget(
          Builder(builder: (context) {
            return Actions(
              actions: getFavoriteActions(context),
              child: const FavoritesList(),
            );
          }),
        ),
      );
    });

    testWidgets(
      'correct content shown based on favorites status',
      (WidgetTester tester) async {
        await tester.pumpWidget(widget);

        //while favorites are loading from storage, a progress indicator should be shown
        favoritesCubit.emit(const FavoritesState(
          status: LoadingStatus.loading,
          favorites: [],
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        //if loading fails show error retry widget
        favoritesCubit.emit(const FavoritesState(
          status: LoadingStatus.error,
          favorites: [],
        ));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey(AppKey.favoritesErrorRetryWidget)),
            findsOneWidget);

        //if there are not favorites, a text should be shown
        favoritesCubit.emit(const FavoritesState(
          status: LoadingStatus.loaded,
          favorites: [],
        ));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey(AppKey.favoritesNoFavoritesText)),
            findsOneWidget);

        //if there are some favorites, the quote widgets should be shown
        favoritesCubit.emit(FavoritesState(
          status: LoadingStatus.loaded,
          favorites: [
            Favorite(
                quote: const Quote(
                  text: 'xyz',
                  author: 'author1',
                  source: 'test',
                  tags: ['tag1', 'tag2'],
                ),
                timeAdded: DateTime(2022)),
            Favorite(
                quote: const Quote(
                  text: 'abc',
                  author: 'author2',
                  source: 'test',
                  tags: ['tag3', 'tag4'],
                ),
                timeAdded: DateTime(2022)),
          ],
        ));
        await waitForBloc(tester);
        await tester.pumpAndSettle();

        expect(find.byType(QuoteCard), findsNWidgets(2));
        expect(find.text('xyz'), findsOneWidget);
        expect(find.text('abc'), findsOneWidget);

        //results are filtered based on filters
        //when the filter search term changes the list of favorites is updated
        filteredFavoritesBloc.add(const SearchTermChanged(searchTerm: 'abc'));
        await waitForBloc(tester, duration: const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.byType(QuoteCard), findsNWidgets(1));
        expect(find.text('xyz'), findsNothing);
        expect(find.text('abc'), findsOneWidget);
      },
    );

    testWidgets(
      'deleting a favorite and undoing the delete works',
      (WidgetTester tester) async {
        await tester.pumpWidget(widget);

        //if there are some favorites, the quote widgets should be shown
        favoritesCubit.emit(FavoritesState(
          status: LoadingStatus.loaded,
          favorites: [
            Favorite(
                quote: const Quote(
                  text: 'xyz',
                  author: 'author1',
                  source: 'test',
                  tags: ['tag1', 'tag2'],
                ),
                timeAdded: DateTime(2022)),
            Favorite(
                quote: const Quote(
                  text: 'abc',
                  author: 'author2',
                  source: 'test',
                  tags: ['tag3', 'tag4'],
                ),
                timeAdded: DateTime(2022)),
          ],
        ));
        await waitForBloc(tester);
        await tester.pumpAndSettle();

        expect(find.byType(QuoteCard), findsNWidgets(2));
        expect(find.text('xyz'), findsOneWidget);
        expect(find.text('abc'), findsOneWidget);

        //tap delete button on quote
        await tester.tap(
          find.descendant(
              of: find.ancestor(
                  of: find.text('xyz'), matching: find.byType(QuoteCard)),
              matching: find.byType(DeleteFavoriteButton)),
        );
        await tester.pumpAndSettle();
        await waitForBloc(tester, duration: const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.byType(QuoteCard), findsNWidgets(1));
        expect(find.text('xyz'), findsNothing);
        expect(find.text('abc'), findsOneWidget);

        //undo also works
        await tester.tap(
          find.descendant(
              of: find.byType(SnackBar), matching: find.text('Undo')),
        );

        await tester.pumpAndSettle();
        await waitForBloc(tester, duration: const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.byType(QuoteCard), findsNWidgets(2));
        expect(find.text('xyz'), findsOneWidget);
        expect(find.text('abc'), findsOneWidget);
      },
    );
  });
}

//introduce an artifical delay to give the bloc time to process events and update its state
Future<void> waitForBloc(WidgetTester tester,
    {Duration duration = Duration.zero}) {
  return tester.runAsync(() => Future.delayed(duration));
}
