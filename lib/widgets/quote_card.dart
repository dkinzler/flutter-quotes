import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/favorites/favorites_cubit.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/theme/theme.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final TextStyle? quoteTextStyle;
  final TextStyle? authorTextStyle;
  final EdgeInsets padding;
  final bool showFavoriteButton;

  final bool showTags;
  //max number of tags to show, if there are more there will be a button to show all
  //if -1 show all tags by default
  final int maxTagsToShow;
  final void Function(String tag)? onTagPressed;

  const QuoteCard({
    Key? key,
    required this.quote,
    this.quoteTextStyle,
    this.authorTextStyle,
    this.padding = const EdgeInsets.all(16.0),
    this.showFavoriteButton = true,
    this.showTags = true,
    this.maxTagsToShow = 4,
    this.onTagPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              quote.text,
              style: quoteTextStyle,
            ),
            SizedBox(height: context.sizes.spaceM), 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    '- ${quote.author}',
                    style: authorTextStyle,
                  ),
                ),
                if(showFavoriteButton) _FavoriteButton(quote: quote),
              ],
            ),
            if(showTags && quote.tags.isNotEmpty) ...[
              SizedBox(height: context.sizes.spaceM), 
              _QuoteTagList(
                tags: quote.tags,
                maxTagsToShow: maxTagsToShow,
                onTagPressed: onTagPressed,
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final Quote quote;
  final double? iconSize;

  const _FavoriteButton({
    Key? key,
    required this.quote,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var favoritesCubit = context.watch<FavoritesCubit>();
    var isFavorited = favoritesCubit.state.containsQuote(quote);
    return IconButton(
      splashRadius: iconSize != null ? iconSize! + 8 : null,
      icon: Icon(
        isFavorited ? Icons.favorite : Icons.favorite_border,
        color: Colors.pink.shade700,
        size: iconSize,
      ),
      onPressed: () {
        favoritesCubit.toggle(quote);
      },
    );
  }
}

//TODO show an animation here
class _QuoteTagList extends StatefulWidget {
  final List<String> tags;
  //max number of tags to show, if there are more there will be a button to show all
  //if -1 show all tags by default
  final int maxTagsToShow;
  final void Function(String tag)? onTagPressed;

  const _QuoteTagList({
    Key? key,
    required this.tags,
    required this.maxTagsToShow,
    this.onTagPressed,
  }) : super(key: key);

  @override
  State<_QuoteTagList> createState() => _QuoteTagListState();
}

class _QuoteTagListState extends State<_QuoteTagList> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    if(widget.tags.isEmpty) {
      return const Text('No tags');
    }

    var maxTagsToShow = widget.maxTagsToShow;
    if(widget.maxTagsToShow <= 0 || expanded) {
      maxTagsToShow = widget.tags.length;
    }

    var chips =  widget.tags.take(maxTagsToShow).map<Widget>((t) =>
      InputChip(
        label: Text(
          t,
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: widget.onTagPressed != null ? () {
          widget.onTagPressed?.call(t);
        } : null,
      )
    ).toList();

    //TODO this logic is not as easy to follow

    var hasMoreTagsToShow = maxTagsToShow < widget.tags.length; 
    if(hasMoreTagsToShow) {
      chips.add(InputChip(
        label: const Text('Show more'),
        onPressed: () {
          setState(() {
            expanded = true;
          });
        },
      ));
    }

    if(expanded) {
      chips.add(InputChip(
        label: const Text('Show less'),
        onPressed: () {
          setState(() {
            expanded = false;
          });
        },
      ));
    }

    return Wrap(
      spacing: context.sizes.spaceS,
      runSpacing: context.sizes.spaceS,
      children: chips,
    );
  }
}