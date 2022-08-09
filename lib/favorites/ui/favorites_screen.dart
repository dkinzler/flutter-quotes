import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/favorites/bloc/bloc.dart';
import 'package:flutter_sample/favorites/filter/filter.dart';
import 'package:flutter_sample/favorites/ui/filter_bar.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/quote_buttons.dart';
import 'package:flutter_sample/widgets/quote.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var status =
        context.select<FavoritesCubit, LoadingStatus>(((c) => c.state.status));
    var favoritesState = context.watch<FilteredFavoritesBloc>().state;
    var favorites = favoritesState.filteredFavorites;
    if (status == LoadingStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (status == LoadingStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ups, something went wrong.'),
            ElevatedButton.icon(
              onPressed: () {
                context.read<FavoritesCubit>().load();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    } else if (favoritesState.favorites.isEmpty) {
      return const Center(child: Text('You have not favorited any quotes.'));
    } else {
      var layout = context.layout;

      itemBuilder(BuildContext context, int index) {
        var favorite = favorites[index];
        return QuoteCard(
          quote: favorite.quote,
          button: DeleteFavoriteButton(
            favorite: favorite,
          ),
          onTagPressed: (String tag) {
            context.read<FilteredFavoritesBloc>().add(FilterTagAdded(tag: tag));
          },
        );
      }

      ;

      Widget quotesWidget;
      if (layout == Layout.mobile) {
        quotesWidget = ListView.builder(
          itemCount: favorites.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: itemBuilder,
        );
      } else {
        quotesWidget = MasonryGridView.builder(
          crossAxisSpacing: context.sizes.spaceS,
          mainAxisSpacing: context.sizes.spaceS,
          itemCount: favorites.length,
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemBuilder: itemBuilder,
        );
      }

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
            child: quotesWidget,
          ),
        ],
      );
    }
  }
}
