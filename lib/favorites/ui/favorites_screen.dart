import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/filter/filter_bloc.dart';
import 'package:flutter_quotes/favorites/repository/favorites_repository.dart';
import 'package:flutter_quotes/favorites/ui/favorites_list.dart';
import 'package:flutter_quotes/favorites/ui/filter_bar.dart';
import 'package:flutter_quotes/favorites/ui/sliver_favorites_list.dart';
import 'package:flutter_quotes/theme/theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isMobile = context.layout == Layout.mobile;

    Widget child;
    if (isMobile) {
      var padding = context.insets.paddingM;
      //to have more space on mobile for actual quotes
      //the filter bar will be scrolled out of view
      //on non-mobile the filter bar will always stay at the top of the screen
      child = Padding(
        padding: padding,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: context.insets.paddingS,
                child: const FilterBar(),
              ),
            ),
            const SliverFavoritesList(),
          ],
        ),
      );
    } else {
      var spaceL = context.sizes.spaceL;
      child = Column(
        children: [
          Padding(
            padding: context.insets.paddingL,
            child: const FilterBar(),
          ),
          Expanded(
            child: FavoritesList(
              padding: EdgeInsets.fromLTRB(
                spaceL,
                0,
                spaceL,
                spaceL,
              ),
            ),
          ),
        ],
      );
    }

    return BlocProvider<FilteredFavoritesBloc>(
      create: (context) => FilteredFavoritesBloc(
          favoritesRepository: context.read<FavoritesRepository>()),
      child: child,
    );
  }
}
