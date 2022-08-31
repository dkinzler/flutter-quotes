import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/cubit/cubit.dart' hide Status;
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/repository/favorites_repository.dart'
    hide Status;
import 'package:flutter_quotes/favorites/repository/storage/storage.dart';
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
  E.g. while FavoritesRepository loads the favorites of the user from storage, the UI should show a CircularProgressIndicator.
  If the user has not yet favorited any quotes, show a Text widget with text 'You have not favorited any quotes'.
  If the user has filtered the quotes (e.g. by entering a serach term or selecting a particular tag), only show the qutoes that match. 
  This type of test is typically performed by the following steps:
    * create an instance of FavoritesCubit and FilteredFavoritesBloc
    * build the FavoritesList widget
    * update the state of the cubit/bloc
    * check that FavoritesList updates the ui and shows the correct elements

* When we interact with the FavoritesList widget, the state of FavoritesCubit/FilteredFavoritesBloc is updated correctly.
  E.g. when we press on the button to delete a favorite, we expect FavoritesRepository to remove the favorite from storage and
  FavoritesCubit/FilteredFavoritesBloc to update its list of favorites to no longer include the quote.
  This type of test typically takes the following form:
    * create an instance of FavoritesCubit and FilteredFavoritesBloc
    * build the FavoritesListWidget
    * interact with the widget, e.g. by pressing a button
    * check that the state of the cubit/bloc updates correctly
  More examples of this type of test can be found in 'filter_bar_test.dart'.
*/

void main() {
  var exampleFavorites = [
    Favorite(
      quote: const Quote(
        text: 'xyz',
        author: 'author1',
        source: 'test',
        tags: ['tag1', 'tag2'],
      ),
      timeAdded: DateTime(2022),
    ),
    Favorite(
      quote: const Quote(
        text: 'abc',
        author: 'author2',
        source: 'test',
        tags: ['tag3', 'tag4'],
      ),
      timeAdded: DateTime(2022),
    ),
  ];

  group('FavoritesList', () {
    late Widget widget;
    late FavoritesRepository favoritesRepository;
    late FavoritesCubit favoritesCubit;
    late FilteredFavoritesBloc filteredFavoritesBloc;

    setUp(() async {
      favoritesRepository =
          FavoritesRepository(storageType: FavoritesStorageType.mock);
      await favoritesRepository.init('test');
      favoritesCubit = FavoritesCubit(favoritesRepository: favoritesRepository);
      filteredFavoritesBloc = FilteredFavoritesBloc(
        favoritesRepository: favoritesRepository,
        debounceTime: null,
      );
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
        //wait for bloc to process initial events
        await waitForBloc(tester, duration: const Duration(milliseconds: 100));

        //while favorites are loading, a progress indicator should be shown
        filteredFavoritesBloc.emit(const FilteredFavoritesState(
          status: Status.loading,
          favorites: [],
          filteredFavorites: [],
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        //if loading fails show error retry widget
        filteredFavoritesBloc.emit(const FilteredFavoritesState(
          status: Status.error,
          favorites: [],
          filteredFavorites: [],
        ));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey(AppKey.favoritesErrorRetryWidget)),
            findsOneWidget);

        //if there are not favorites, a text should be shown
        filteredFavoritesBloc.emit(const FilteredFavoritesState(
          status: Status.loaded,
          favorites: [],
          filteredFavorites: [],
        ));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey(AppKey.favoritesNoFavoritesText)),
            findsOneWidget);

        //if there are some favorites, the quote widgets should be shown
        filteredFavoritesBloc.emit(FilteredFavoritesState(
          status: Status.loaded,
          favorites: exampleFavorites,
          filteredFavorites: exampleFavorites,
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

        for (final favorite in exampleFavorites) {
          await favoritesCubit.add(favorite.quote);
        }
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
        await waitForBloc(tester, duration: const Duration(milliseconds: 100));
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
        await waitForBloc(tester, duration: const Duration(milliseconds: 100));
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
