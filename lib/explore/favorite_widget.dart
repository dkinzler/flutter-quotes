import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/favorites/bloc/favorite.dart';
import 'package:flutter_sample/favorites/bloc/favorites_cubit.dart';
import 'package:flutter_sample/search/actions.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/card.dart';
import 'package:flutter_sample/widgets/error.dart';
import 'package:flutter_sample/widgets/quote.dart';

class FavoriteWidget extends StatefulWidget {
  const FavoriteWidget({Key? key}) : super(key: key);

  @override
  State<FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  bool loading = true;
  bool hasError = false;
  Favorite? favorite;

  StreamSubscription? _favoriteCubitSubscription;

  @override
  void initState() {
    super.initState();
    var favoritesCubit = context.read<FavoritesCubit>();
    _handleStateChange(favoritesCubit.state);
    _favoriteCubitSubscription =
        context.read<FavoritesCubit>().stream.listen(_handleStateChange);
  }

  void _handleStateChange(FavoritesState state) {
    if (state.status == LoadingStatus.loading) {
      setState(() {
        loading = true;
        hasError = false;
        favorite = null;
      });
    } else if (state.status == LoadingStatus.error) {
      setState(() {
        loading = false;
        hasError = true;
        favorite = null;
      });
    } else {
      Favorite? f;
      if (state.favorites.isNotEmpty) {
        f = state.favorites[Random().nextInt(state.favorites.length)];
      }
      setState(() {
        loading = false;
        hasError = false;
        favorite = f;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = Padding(
        padding: context.insets.paddingM,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (hasError) {
      content = ErrorRetryWidget(
        onPressed: () => context.read<FavoritesCubit>().load(),
      );
    } else if (favorite == null) {
      content = Padding(
        padding: context.insets.paddingM,
        child: const Text('You have not added any quotes to favorites'),
      );
    } else {
      content = QuoteWidget(
        quote: favorite!.quote,
        onTagPressed: (String tag) {
          Actions.invoke<SearchIntent>(
              context,
              SearchIntent(
                gotoSearchScreen: true,
                query: tag,
              ));
        },
      );
    }

    return CustomCard(
      header: Text(
        'From your favorites',
        style: context.theme.textTheme.headlineSmall,
      ),
      content: content,
    );
  }

  @override
  void dispose() {
    _favoriteCubitSubscription?.cancel();
    super.dispose();
  }
}
