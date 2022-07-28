import 'package:flutter/material.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/card.dart';
import 'package:flutter_sample/widgets/quote_tags.dart';

class QuoteWidget extends StatelessWidget {
  final Quote quote;

  final TextStyle? quoteTextStyle;
  final TextStyle? authorTextStyle;

  final Widget? button;

  final bool showTags;
  //max number of tags to show, if there are more there will be a button to show all
  //if -1 show all tags by default
  final int maxTagsToShow;
  final void Function(String tag)? onTagPressed;

  const QuoteWidget({
    Key? key,
    required this.quote,
    this.quoteTextStyle,
    this.authorTextStyle,
    this.button,
    this.showTags = true,
    this.maxTagsToShow = 4,
    this.onTagPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var quoteTextWidgets = <Widget>[
      Text(
        quote.text,
        style: quoteTextStyle,
      ),
      SizedBox(height: context.sizes.spaceM),
      Text(
        '-${quote.author}',
        style: authorTextStyle,
      ),
      /*
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
          if (button != null) button!,
        ],
      ),
      */
    ];

    Widget? tagsWidget;
    if (showTags && quote.tags.isNotEmpty) {
      tagsWidget = QuoteTagList(
        tags: quote.tags,
        maxTagsToShow: maxTagsToShow,
        onTagPressed: onTagPressed,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...quoteTextWidgets,
        if (tagsWidget != null) ...[
          SizedBox(height: context.sizes.spaceM),
          tagsWidget,
        ],
        if (button != null) ...[
          button!,
          SizedBox(height: context.sizes.spaceM),
        ],
      ],
    );
  }
}

class QuoteCard extends CustomCard {
  final Quote quote;

  final TextStyle? quoteTextStyle;
  final TextStyle? authorTextStyle;

  final Widget? button;

  final bool showTags;
  //max number of tags to show, if there are more there will be a button to show all
  //if -1 show all tags by default
  final int maxTagsToShow;
  final void Function(String tag)? onTagPressed;

  QuoteCard({
    Key? key,
    required this.quote,
    this.quoteTextStyle,
    this.authorTextStyle,
    this.button,
    this.showTags = true,
    this.maxTagsToShow = 4,
    this.onTagPressed,
  }) : super(
            key: key,
            content: QuoteWidget(
              quote: quote,
              quoteTextStyle: quoteTextStyle,
              authorTextStyle: authorTextStyle,
              button: button,
              showTags: showTags,
              maxTagsToShow: maxTagsToShow,
              onTagPressed: onTagPressed,
            ));
}
