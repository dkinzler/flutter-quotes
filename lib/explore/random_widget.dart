import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/explore/random_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/quote_card.dart';

class PrevIntent extends Intent {
  const PrevIntent();
}

class NextIntent extends Intent {
  const NextIntent();
}

class RandomQuoteWidget extends StatefulWidget {
  const RandomQuoteWidget({Key? key}) : super(key: key);

  @override
  State<RandomQuoteWidget> createState() => _RandomQuoteWidgetState();
}

class _RandomQuoteWidgetState extends State<RandomQuoteWidget> {
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

    Widget child;

    if(state.quote != null) {
      var quote = state.quote!;
      child = GestureDetector(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                //TODO remove this animation, change it back to fade maybe?
                //or can we slide it in within the widget
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
                  child: QuoteTextWidget(
                    key: ValueKey(quote.sourceId ?? quote.text),
                    quote: quote,
                    /*
                    onTagPressed: (String tag) {
                      Actions.invoke<SearchIntent>(context, SearchIntent(
                        gotoSearchScreen: true,
                        query: tag,
                      ));
                    },
                    */
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
    } else if(state.status == LoadingStatus.loading) {
      child = const Center(child: CircularProgressIndicator());
    } else {
      child = Column(
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
      );
    }

    return Center(
      child: Card(
        child: Padding(
          padding: context.insets.paddingM,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Random Quote',
                style: context.theme.textTheme.headlineSmall,
              ),
              Divider(
                thickness: context.sizes.spaceXS,
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}