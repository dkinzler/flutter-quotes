import 'package:flutter/material.dart';
import 'package:flutter_quotes/routing/routing.dart';
import 'package:flutter_quotes/search/cubit/search_cubit.dart';
import 'package:provider/provider.dart';

/*
We can use intents and actions as a more general approach to implementing actions a user can perform in the app.
Take search in this app as an example. There are different ways in different parts of the app to start a search for quotes.
E.g. on the search page the user can type a query into a text field and press the search button to initiate a search. 
Tapping on a tag of a quote on the explore or search screen will also take the user to the search screen and start a search with the selected tag as the query.
The straightforward way to implement these behaviors is by initiating the search in the onPressed callbacks of the search button and the quote tag, e.g.

ElevatedButton(
  child: const Text('Search'),
  onPressed: () {
    //read query e.g. from text controller
    String query = ...;
    context.read<SearchCubit>().search(query: query);
  }
);

We would use a similar callback function, that calls the search method of the search cubit, for every place in the app, where the user can start a search.
The code to start the search will be duplicated multiple times and the UI/widget code is coupled to the particular way the "backend" part of the search is implemented (in the example with a cubit).

A better and more general approach is to split the intent of the user (the thing/action they want to perform) from the actual code/implementation that performs that intent.
I.e. we define an intent class that captures what the user wants to do and an action class that contains the code that will actually perform the action given an intent instance. 
In the example the user wants to perform a search for a particular query, so the intent class would consist of just that query string. 
The action class will take an instance of the intent and pass the query along to the search cubit.

If we later want to change the search backend, we just have to touch the action class and nothing else.

Flutter already provides a neat way to implement intents and actions by extending the Intent and Action class.
Furthermore an Actions widget can be inserted into the widget tree, that defines which intents are performed by which actions. 
An action can then be invoked from anywhere in the widget tree below the Actions widget, by creating an intent instance and e.g. calling:

Actions.invoke(context, SearchIntent(query: query))
*/

class SearchIntent extends Intent {
  final String? query;
  final bool gotoSearchScreen;

  const SearchIntent({
    required this.query,
    this.gotoSearchScreen = false,
  });
}

class SearchAction extends Action<SearchIntent> {
  final AppRouter appRouter;
  final SearchCubit searchCubit;

  SearchAction({
    required this.appRouter,
    required this.searchCubit,
  });

  @override
  void invoke(SearchIntent intent) {
    if (intent.gotoSearchScreen) {
      appRouter.go(const HomeRoute(tab: HomeTab.search));
    }
    searchCubit.search(query: intent.query);
  }
}

Map<Type, Action<Intent>> getSearchActions(BuildContext context) {
  return <Type, Action<Intent>>{
    SearchIntent: SearchAction(
      appRouter: context.read<AppRouter>(),
      searchCubit: context.read<SearchCubit>(),
    )
  };
}
