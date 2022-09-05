import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/cubit/cubit.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/favorites/widgets/actions.dart';
import 'package:flutter_quotes/quote/model/quote.dart';

class _QuoteFavoriteState extends Equatable {
  final bool isFavorited;
  final bool isEnabled;

  const _QuoteFavoriteState(
      {required this.isFavorited, required this.isEnabled});

  @override
  List<Object?> get props => [isFavorited, isEnabled];
}

class FavoriteButton extends StatelessWidget {
  final Quote quote;
  final double? iconSize;

  const FavoriteButton({
    Key? key,
    required this.quote,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //while the favorites of the user have not been loaded successfully, the button should be disabled
    var fs = context.select<FavoritesCubit, _QuoteFavoriteState>((c) =>
        _QuoteFavoriteState(
            isFavorited: c.state.containsQuote(quote),
            isEnabled: c.state.status.isLoaded));
    return IconButton(
      splashRadius: iconSize != null ? iconSize! + 8 : null,
      icon: Icon(
        fs.isFavorited ? Icons.favorite : Icons.favorite_border,
        color: fs.isEnabled ? Colors.pink.shade700 : Colors.grey,
        size: iconSize,
      ),
      onPressed: fs.isEnabled
          ? () {
              Actions.invoke<ToggleFavoriteIntent>(
                  context, ToggleFavoriteIntent(quote: quote));
            }
          : null,
    );
  }
}

class DeleteFavoriteButton extends StatelessWidget {
  final Favorite favorite;
  final double? iconSize;

  const DeleteFavoriteButton({
    Key? key,
    required this.favorite,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: iconSize != null ? iconSize! + 8 : null,
      icon: Icon(
        Icons.delete,
        size: iconSize,
      ),
      onPressed: () {
        Actions.invoke<DeleteFavoriteIntent>(
            context,
            DeleteFavoriteIntent(
              favorite: favorite,
            ));
      },
    );
  }
}
