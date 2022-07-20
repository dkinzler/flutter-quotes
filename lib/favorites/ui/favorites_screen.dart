import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/favorites/ui/actions.dart';
import 'package:flutter_sample/favorites/bloc/bloc.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/quote_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

//TODO show autocomplete for search field?

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var status = context.select<FavoritesCubit, LoadingStatus>(((c) => c.state.status));
    var favoritesState = context.watch<FilteredFavoritesBloc>().state;
    var favorites = favoritesState.filteredFavorites;
    if(status == LoadingStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if(status == LoadingStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ups, something went wrong.'),
            ElevatedButton.icon(
              onPressed: (){
                context.read<FavoritesCubit>().load();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    } else if(favoritesState.favorites.isEmpty) {
      return const Center(
        child: Text('You have not favorited any quotes.')
      );
    } else {
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: FilterBar(),
          ),
          Expanded(
            child: MasonryGridView.builder(
              crossAxisSpacing: context.sizes.spaceS,
              mainAxisSpacing: context.sizes.spaceS,
              itemCount: favorites.length,
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                var favorite = favorites[index];
                return QuoteCard(
                  quote: favorite.quote,
                  showFavoriteButton: false,
                  onDeleteButtonPressed: () {
                    Actions.invoke<DeleteFavoriteIntent>(context, DeleteFavoriteIntent(
                      favorite: favorite,
                    ));
                  },
                  onTagPressed: (String tag) {
                    context.read<FilteredFavoritesBloc>().add(FilterTagAdded(tag: tag));
                  },
                );
              }, 
            ),
          ),
        ],
      );
    }
  }
}

class FilterBar extends StatefulWidget {
  const FilterBar({Key? key}) : super(key: key);

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final _searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //TODO remove listener or not necessary? google this
    _searchFieldController.addListener(() {
      context.read<FilteredFavoritesBloc>().add(SearchTermChanged(searchTerm: _searchFieldController.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<FilteredFavoritesBloc>().state;
    var sort = state.sortOrder;
    
    List<Widget> children = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: _searchFieldController,
            ),
          ),
          PopupMenuButton<SortOrder>(
            initialValue: sort,
            onSelected: ((value) {
              context.read<FilteredFavoritesBloc>().add(SortOrderChanged(sortOrder: value));
            }),
            itemBuilder: (context) => <PopupMenuEntry<SortOrder>>[
              const PopupMenuItem<SortOrder>(
                value: SortOrder.newest,
                child: Text('Newest'),
              ),
              const PopupMenuItem<SortOrder>(
                value: SortOrder.oldest,
                child: Text('Oldest'),
              ),
            ],
            child: Text(
              sort == SortOrder.newest ? 'Sort by: newest' : 'Sort by: oldest',
            ),
          ),
        ],
      ),
    ];

    var searchTerm = state.filters.searchTerm;
    if(searchTerm != null && searchTerm.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ),
        child: Center(
          child: Text('Showing results for "$searchTerm"'),
        ),
      ));
    }

    var tags = state.filters.tags;
    if(tags.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Wrap(
          spacing: context.sizes.spaceS,
          runSpacing: context.sizes.spaceS,
          children: tags.map<Widget>((t) => InputChip(
            label: Text(t),
            onDeleted: () {
              context.read<FilteredFavoritesBloc>().add(FilterTagRemoved(tag: t));
            },
          )).toList(),
        ),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}