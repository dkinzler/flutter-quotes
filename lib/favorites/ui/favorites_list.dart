import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/bloc/bloc.dart';
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/theme/theme.dart';
import 'package:flutter_quotes/widgets/error.dart';
import 'package:flutter_quotes/widgets/quote.dart';
import 'package:flutter_quotes/widgets/quote_buttons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FavoritesList extends StatelessWidget {
  final EdgeInsetsGeometry? padding;

  const FavoritesList({
    Key? key,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var status =
        context.select<FavoritesCubit, LoadingStatus>(((c) => c.state.status));
    var state = context.watch<FilteredFavoritesBloc>().state;
    var favorites = state.favorites;
    var filteredFavorites = state.filteredFavorites;

    Widget? child;
    if (status == LoadingStatus.loading) {
      child = const CircularProgressIndicator();
    } else if (status == LoadingStatus.error) {
      child = ErrorRetryWidget(
        onPressed: () => context.read<FavoritesCubit>().load(),
      );
    } else if (favorites.isEmpty) {
      child = const Text('You have not favorited any quotes.');
    }

    if (child != null) {
      return Center(
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      );
    }

    itemBuilder(BuildContext context, int index) {
      var favorite = filteredFavorites[index];
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

    Widget quotesWidget;

    //compute number of columns based on the size of the screen
    //we might want to use a LayoutBuilder to get the actual size that will be available to this widget, not the total size of the screen
    //however the only other widget that takes up width is the nav bar, so this is good enough
    var width = MediaQuery.of(context).size.width - 64;
    int numColumns = max((width / context.appTheme.scale / 400).floor(), 1);

    if (numColumns == 1) {
      quotesWidget = ListView.builder(
        itemCount: filteredFavorites.length,
        padding: padding,
        itemBuilder: itemBuilder,
      );
    } else {
      quotesWidget = MasonryGridView.builder(
        crossAxisSpacing: context.sizes.spaceS,
        mainAxisSpacing: context.sizes.spaceS,
        itemCount: filteredFavorites.length,
        padding: padding,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: numColumns),
        itemBuilder: itemBuilder,
      );
    }
    return quotesWidget;
  }
}
