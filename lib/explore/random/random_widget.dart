import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/explore/random/random_cubit.dart';
import 'package:flutter_quotes/explore/widgets/header.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/search/widgets/actions.dart';
import 'package:flutter_quotes/theme/theme.dart';
import 'package:flutter_quotes/widgets/error.dart';
import 'package:flutter_quotes/favorites/widgets/buttons.dart';
import 'package:flutter_quotes/quote/widgets/quote.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class RandomQuoteWidget extends StatefulWidget {
  //number of quotes to show
  final int numQuotes;
  //how many quotes to show side by side
  final int numColumns;
  final bool expand;

  const RandomQuoteWidget({
    Key? key,
    required this.numQuotes,
    this.numColumns = 1,
    this.expand = false,
  }) : super(key: key);

  @override
  State<RandomQuoteWidget> createState() => _RandomQuoteWidgetState();
}

class _RandomQuoteWidgetState extends State<RandomQuoteWidget> {
  int get numQuotes => widget.numQuotes;
  int get numColumns => widget.numColumns;

  @override
  void initState() {
    super.initState();
    context.read<RandomCubit>().loadQuotes(numQuotes);
  }

  void _refreshQuotes() {
    context.read<RandomCubit>().loadQuotes(numQuotes);
  }

  @override
  Widget build(BuildContext context) {
    var randomCubit = context.watch<RandomCubit>();
    var state = randomCubit.state;

    Widget child;
    if (state.status == LoadingStatus.error) {
      child = Center(
        child: Padding(
          padding: context.insets.paddingM,
          child: ErrorRetryWidget(
            key: const ValueKey(AppKey.exploreRandomErrorRetryWidget),
            onPressed: () => randomCubit.loadQuotes(numQuotes),
          ),
        ),
      );
    } else if (state.quotes.isEmpty) {
      child = const SizedBox.shrink();
    } else {
      if (numQuotes == 1) {
        var q = state.quotes.first;
        child = QuoteCard(
          quote: q,
          button: FavoriteButton(
            quote: q,
          ),
          onTagPressed: (String tag) {
            Actions.invoke<SearchIntent>(
                context,
                SearchIntent(
                  query: tag,
                  gotoSearchScreen: true,
                ));
          },
        );
      } else {
        /*
        child = MasonryGridView(
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: numColumns),
          children: state.quotes
              .map<Widget>((q) => QuoteCard(
                    quote: q,
                    button: FavoriteButton(
                      quote: q,
                    ),
                    onTagPressed: (String tag) {
                      Actions.invoke<SearchIntent>(
                          context,
                          SearchIntent(
                            query: tag,
                            gotoSearchScreen: true,
                          ));
                    },
                  ))
              .toList(),
        );
        */
        child = MasonryGridView.count(
          crossAxisCount: numColumns,
          itemCount: state.quotes.length,
          itemBuilder: (context, index) {
            var q = state.quotes[index];
            return QuoteCard(
              quote: q,
              button: FavoriteButton(
                quote: q,
              ),
              onTagPressed: (String tag) {
                Actions.invoke<SearchIntent>(
                    context,
                    SearchIntent(
                      query: tag,
                      gotoSearchScreen: true,
                    ));
              },
            );
          },
        );
      }
    }

    child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: child,
    );

    if (widget.expand) {
      child = Expanded(child: child);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Header(
          text: 'Random quotes',
          trailing: Builder(
            builder: (context) {
              var status = context
                  .select<RandomCubit, LoadingStatus>((c) => c.state.status);

              Widget child;
              if (status == LoadingStatus.loading) {
                child = const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                child = IconButton(
                  key: const ValueKey(AppKey.exploreRandomReloadButton),
                  icon: const Icon(Icons.refresh),
                  iconSize: 32.0,
                  constraints: BoxConstraints.tight(const Size(48, 48)),
                  onPressed:
                      status == LoadingStatus.idle ? _refreshQuotes : null,
                );
              }
              return child;
            },
          ),
        ),
        SizedBox(height: context.sizes.spaceS),
        child,
      ],
    );
  }
}
