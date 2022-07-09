import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/actions/search.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/random/random_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/quote_card.dart';

class PrevIntent extends Intent {
  const PrevIntent();
}

class NextIntent extends Intent {
  const NextIntent();
}

//TODO this needs some cleaning up
//TODO coudl also add a button to favorite/unfavorite
class RandomScreen extends StatefulWidget {
  const RandomScreen({Key? key}) : super(key: key);

  @override
  State<RandomScreen> createState() => _RandomScreenState();
}

class _RandomScreenState extends State<RandomScreen> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var quotes = context.select<RandomCubit, List<Quote>>((c) => c.state.quotes);
    if(quotes.isNotEmpty) {
      //TODO rewrite this comment since we switched to more involved approach
      //Flutter provides a more general mechanism to implement keyboard shortucts using Actions, Intents/Shortcuts.
      //However for a simple app like this it's probably overkill, would just add a lot of boilerplate code.
      return FocusableActionDetector(
        shortcuts: <ShortcutActivator, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PrevIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextIntent(),
        },
        actions: <Type, Action<Intent>>{
          PrevIntent: CallbackAction<PrevIntent>(
            onInvoke: (PrevIntent intent) {
              context.read<RandomCubit>().prev();
            }
          ),
          NextIntent: CallbackAction<NextIntent>(
            onInvoke: (NextIntent intent) {
              context.read<RandomCubit>().next();
            }
          ),
        },
        focusNode: _focusNode,
        autofocus: true,
        //give focus back to this widget sub-tree when clicking anywhere
        //so that keyboard shortcuts can be handled again

        //TODO if we keep MouseRegion here comment what behaviour we could have implemente dusing gesturedetector
        //child: GestureDetector(
        //  onTap: () => _focusNode.requestFocus(),
        //TODO we could also make this not work by clicking, but just by hovering inside with the mouse
        child: MouseRegion(
          onEnter: (_) => _focusNode.requestFocus(),
          child: Column(
            children: [
              //TODO there is a bug where when we skip images with the next button before they are loaded they fail to laod afterwards
              //that probably has something to do with all the image size loading stuff
              /*
              AnimatedSwitcher(
                duration: const Duration(milliseconds : 500),
                reverseDuration: const Duration(seconds :1),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  var isForward = animation.status == AnimationStatus.forward ||
                    animation.status == AnimationStatus.completed;
                  Animation<Offset> position;
                  if(isForward) {
                    position = Tween<Offset>(
                      begin: const Offset(-2.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation);
                  } else {
                    position = Tween<Offset>(
                      begin: const Offset(2.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation);
                  }
                  return SlideTransition(
                    position: position,
                    child: child,
                  );
                },
                child: QuoteCard(
                  key: ValueKey(quote.id ?? quote.text),
                  quote: quote,
                  onTagPressed: (String tag) {
                    Actions.invoke<SearchIntent>(context, SearchIntent(
                      gotoSearchScreen: true,
                      query: tag,
                    ));
                  },
                ),
              ),
              */
              SizedBox(height: context.sizes.spaceM),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<RandomCubit>().prev();
                    },
                    child: const Text('Prev'),
                  ),
                  SizedBox(width: context.sizes.spaceS),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RandomCubit>().next();
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if(state.status == Status.loading) {
      //TODO if there already are some images we should show prev/next buttons here
     return const Center(child: CircularProgressIndicator());
    } else {
      return Center(
        child: Column(
          children: [
            const Text('Something went wrong...'),
            ElevatedButton(
              onPressed: () {
                context.read<RandomCubit>().loadMore();
              },
              child: const Text('Try Again'),
            ),
          ],
        )
      );
    }
  }
}