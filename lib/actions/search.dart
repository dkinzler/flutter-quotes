import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sample/routing/routing.dart';
import 'package:flutter_sample/search/search_cubit.dart';

class SearchIntent extends Intent {
  final bool gotoSearchScreen;
  final String query;

  const SearchIntent({
    required this.gotoSearchScreen,
    required this.query,
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
    if(intent.gotoSearchScreen) {
      appRouter.go(const HomeRoute(tab: HomeTab.search));
    }
    searchCubit.search(query: intent.query);
  }
}

class DialogIntent extends Intent {}

class DialogAction extends ContextAction<DialogIntent> {
  @override
  Future<void> invoke(DialogIntent intent, [BuildContext? context]) async {
    if(context != null) {
      await showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text('hello'),
        ),
      );
    }
  }
}