import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/explore/random/random_cubit.dart';
import 'package:flutter_sample/search/actions.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/card.dart';
import 'package:flutter_sample/widgets/error.dart';
import 'package:flutter_sample/widgets/quote_buttons.dart';
import 'package:flutter_sample/widgets/quote.dart';

class RandomQuoteWidget extends StatelessWidget {
  const RandomQuoteWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      header: Text(
        'Random Quote',
        style: context.theme.textTheme.headlineSmall,
      ),
      content: Builder(
        builder: (context) {
          var randomCubit = context.watch<RandomCubit>();
          var state = randomCubit.state;

          Widget child;
          if (state.quote != null) {
            var quote = state.quote!;
            child = QuoteWidget(
              key: ValueKey(quote.id),
              quote: state.quote!,
              button: QuoteFavoriteButton(
                quote: quote,
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
          } else if (state.status == LoadingStatus.loading) {
            child = Center(
              child: Padding(
                padding: context.insets.paddingM,
                child: const CircularProgressIndicator(),
              ),
            );
          } else {
            child = ErrorRetryWidget(
              onPressed: () => randomCubit.next(),
            );
          }

          /*
          return PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
                FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            ),
            child: child,
          );
          */
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
      ),
      trailing: Builder(builder: (context) {
        var state = context.watch<RandomCubit>().state;
        var status = state.status;
        if (state.quote != null || status == LoadingStatus.loading) {
          var isEnabled = state.quote != null;
          return ElevatedButton(
            onPressed:
                isEnabled ? () => context.read<RandomCubit>().next() : null,
            child: const Text('Next'),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}
