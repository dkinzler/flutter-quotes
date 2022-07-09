import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/favorites/filter_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/quote_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

//TODO show autocomplete for search field?

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var favoritesState = context.watch<FilterCubit>().state;
    var favorites = favoritesState.filteredFavorites;
    if(favoritesState.status == FilterStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
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
          if(favoritesState.searchTerm != null && favoritesState.searchTerm!.isNotEmpty) 
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: Center(
                child: Text('Showing results for "${favoritesState.searchTerm}"'),
              ),
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
      context.read<FilterCubit>().setSearchTerm(_searchFieldController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    var sort = context.watch<FilterCubit>().state.sort;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            controller: _searchFieldController,
          ),
        ),
        PopupMenuButton<Sort>(
          initialValue: sort,
          onSelected: ((value) {
            context.read<FilterCubit>().setSort(value);
          }),
          itemBuilder: (context) => <PopupMenuEntry<Sort>>[
            const PopupMenuItem<Sort>(
              value: Sort.newest,
              child: Text('Newest'),
            ),
            const PopupMenuItem<Sort>(
              value: Sort.oldest,
              child: Text('Oldest'),
            ),
          ],
          child: Text(
            sort == Sort.newest ? 'Sort by: newest' : 'Sort by: oldest',
          ),
        ),
      ],
    );
  }
}