import 'package:flutter/material.dart';
import 'package:flutter_quotes/favorites/cubit/cubit.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/quote/model/quote.dart';
import 'package:provider/provider.dart';

/*
Can either provide a Favorite or a Quote to toggle the favorite status.
*/
class ToggleFavoriteIntent extends Intent {
  final Favorite? favorite;
  final Quote? quote;
  final bool showConfirmDialogOnRemove;

  const ToggleFavoriteIntent({
    this.favorite,
    this.quote,
    this.showConfirmDialogOnRemove = false,
  }) : assert(favorite != null || quote != null);
}

class ToggleFavoriteAction extends ContextAction<ToggleFavoriteIntent> {
  final FavoritesCubit favoritesCubit;

  ToggleFavoriteAction({
    required this.favoritesCubit,
  });

  @override
  Future<void> invoke(ToggleFavoriteIntent intent,
      [BuildContext? context]) async {
    var quote = intent.quote ?? intent.favorite?.quote;
    if (quote == null) {
      return;
    }
    var isFavorited = favoritesCubit.state.containsQuote(quote);
    if (isFavorited && intent.showConfirmDialogOnRemove && context != null) {
      var confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text('Do you really want to unfavorite this quote?'),
            actions: [
              ElevatedButton(
                child: const Text('No'),
                onPressed: () => Navigator.of(context).pop<bool>(false),
              ),
              ElevatedButton(
                child: const Text('Yes'),
                onPressed: () => Navigator.of(context).pop<bool>(true),
              ),
            ],
          );
        },
        barrierDismissible: false,
        useRootNavigator: true,
      );
      if (confirmed == true) {
        await favoritesCubit.toggle(quote);
      }
    } else {
      await favoritesCubit.toggle(quote);
    }
  }
}

/*
This will show a snackbar to undo the deletion.
*/
class DeleteFavoriteIntent extends Intent {
  final Favorite favorite;
  final bool showUndoSnackBar;
  final Duration undoSnackBarDuration;

  const DeleteFavoriteIntent({
    required this.favorite,
    this.showUndoSnackBar = true,
    this.undoSnackBarDuration = const Duration(seconds: 6),
  });
}

class DeleteFavoriteAction extends ContextAction<DeleteFavoriteIntent> {
  final FavoritesCubit favoritesCubit;

  DeleteFavoriteAction({
    required this.favoritesCubit,
  });

  @override
  Future<void> invoke(DeleteFavoriteIntent intent,
      [BuildContext? context]) async {
    favoritesCubit.remove(favorite: intent.favorite);
    if (context != null && intent.showUndoSnackBar) {
      var scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      scaffoldMessenger?.hideCurrentSnackBar();
      scaffoldMessenger?.showSnackBar(
        SnackBar(
          content: const Text('Favorite deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              favoritesCubit.add(intent.favorite.quote);
            },
          ),
          duration: intent.undoSnackBarDuration,
        ),
      );
    }
  }
}

Map<Type, Action<Intent>> getFavoriteActions(BuildContext context) {
  return <Type, Action<Intent>>{
    ToggleFavoriteIntent: ToggleFavoriteAction(
      favoritesCubit: context.read<FavoritesCubit>(),
    ),
    DeleteFavoriteIntent: DeleteFavoriteAction(
      favoritesCubit: context.read<FavoritesCubit>(),
    ),
  };
}
