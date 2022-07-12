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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<RandomCubit>().state;

    if(state.status == LoadingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if(state.status == LoadingStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ups, something went wrong.'),
            ElevatedButton.icon(
              onPressed: (){
                context.read<RandomCubit>().next();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try again')
            ),
          ],
        ),
      );
    } else {
      var quote = state.quote!;
      return GestureDetector(
        onPanEnd: (details) {
          if(details.velocity.pixelsPerSecond.dx < 0) {
            context.read<RandomCubit>().next();
          }
        },
        child: FocusableActionDetector(
          shortcuts: <ShortcutActivator, Intent>{
            LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PrevIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextIntent(),
          },
          actions: <Type, Action<Intent>>{
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    bool isForward = animation.status == AnimationStatus.forward || animation.status == AnimationStatus.completed;

                    Animation<Offset> position;
                    if(isForward) {
                      position = Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(animation);
                    } else {
                      position = Tween<Offset>(
                        begin: const Offset(1, 0),
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
                SizedBox(height: context.sizes.spaceM),
                ElevatedButton(
                  onPressed: () {
                    context.read<RandomCubit>().next();
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}