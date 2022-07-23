import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/search/search_bar.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/error.dart';
import 'package:flutter_sample/widgets/quote.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

//TODO below search bar show a little text: Results for "xyz", 1337 Results found

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

//We use the AutomaticKeepAliveClientMixin to keep this widget in the widget tree
//when we switch between tabs on the home screen.
//This is to be at the same scroll position when we move from the search screen tab to another tab and back.
//Keeping the widget around even when it's not visible will of course consume more memory, on web/desktop this should be fine.
//Normally we could more easily remember the scroll position by using a PageStorageKey
//for the ListView/GridView.
//This works for the ListView widget but not for the MasonryGridView widget from the
//flutter_staggered_grid_view package, this is probably a bug in that package.
class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const SearchBar(),
        SizedBox(height: context.sizes.spaceM),
        const Expanded(child: SearchResultsWidget()),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SearchResultsWidget extends StatefulWidget {
  const SearchResultsWidget({Key? key}) : super(key: key);

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  final _scrollController = ScrollController();
  bool _loadInProgress = false;

  //TODO need to make sure this is only used when there are actually more results to load
  //e.g. if there was an error we would want to show a button and not retry automatically
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() async {
      var trigger = 0.9 * _scrollController.position.maxScrollExtent;
      if (!_loadInProgress && _scrollController.position.pixels > trigger) {
        _loadInProgress = true;
        await context.read<SearchCubit>().loadMoreResults();
        _loadInProgress = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<SearchCubit>().state;
    if (!state.hasResults) {
      if (state.status == SearchStatus.idle) {
        return const Center(
          child: Text('Enter a search term...'),
        );
      } else if (state.status == SearchStatus.inProgress) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ups, something went wrong.'),
              ElevatedButton(
                child: const Text('Try again'),
                onPressed: () {
                  context.read<SearchCubit>().search();
                },
              ),
            ],
          ),
        );
      }
    } else {
      var quotes = state.quotes!;
      if (quotes.isEmpty) {
        return const Text('No results found');
      }

      var itemCount = quotes.length + 1;

      Widget resultList;
      if (context.layout == Layout.desktop) {
        var width = MediaQuery.of(context).size.width;
        var numColumns = max(width / context.appTheme.scale / 400, 1).floor();

        resultList = MasonryGridView.builder(
          controller: _scrollController,
          crossAxisSpacing: context.sizes.spaceS,
          mainAxisSpacing: context.sizes.spaceS,
          itemCount: itemCount,
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: numColumns),
          padding: const EdgeInsets.all(32.0),
          //TODO make this more dry, itembuilder is the same for gridview and listview
          itemBuilder: (context, index) {
            if (index == itemCount - 1) {
              if (state.status == SearchStatus.inProgress) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (!state.canLoadMore) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No more results'),
                  ),
                );
              } else if (state.status == SearchStatus.error) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Ups, something went wrong'),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SearchCubit>().loadMoreResults();
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                );
              } else {
                return ElevatedButton(
                  onPressed: () {
                    context.read<SearchCubit>().loadMoreResults();
                  },
                  child: const Text('Load more'),
                );
              }
            }
            return QuoteCard(
              quote: quotes[index],
              quoteTextStyle: const TextStyle(color: Colors.white),
              authorTextStyle: const TextStyle(color: Colors.white),
              showTags: true,
              onTagPressed: (String tag) {
                context.read<SearchCubit>().search(query: tag);
              },
            );
          },
        );
      } else {
        resultList = ListView.builder(
          controller: _scrollController,
          itemCount: itemCount,
          padding: const EdgeInsets.all(32.0),
          itemBuilder: (context, index) {
            if (index == itemCount - 1) {
              if (state.status == SearchStatus.inProgress) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (!state.canLoadMore) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No more results'),
                  ),
                );
              } else if (state.status == SearchStatus.error) {
                return ErrorRetryWidget(
                  onPressed: () {
                    context.read<SearchCubit>().loadMoreResults();
                  },
                );
              } else {
                return ElevatedButton(
                  onPressed: () {
                    context.read<SearchCubit>().loadMoreResults();
                  },
                  child: const Text('Load more'),
                );
              }
            }
            return QuoteCard(
              quote: quotes[index],
              quoteTextStyle: const TextStyle(color: Colors.white),
              authorTextStyle: const TextStyle(color: Colors.white),
              showTags: true,
              onTagPressed: (String tag) {
                context.read<SearchCubit>().search(query: tag);
              },
            );
          },
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Showing results for: ${state.query}',
            ),
          ),
          Expanded(
            child: resultList,
          ),
        ],
      );
    }
  }
}
