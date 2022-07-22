import 'package:flutter/material.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/quote_buttons.dart';
import 'package:flutter_sample/widgets/quote_tags.dart';

//TODO can we make this more dry?

class QuoteCard extends StatelessWidget {
  final Quote quote;

  final TextStyle? quoteTextStyle;
  final TextStyle? authorTextStyle;

  final Widget? header;
  final Widget? button;
  final Widget? trailing;

  //defaults to theme.insets.paddingM
  final EdgeInsets? padding;

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
    this.header,
    this.button,
    this.trailing,
    this.padding,
    this.showTags = true,
    this.maxTagsToShow = 4,
    this.onTagPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var padding = this.padding ?? context.insets.paddingM;

    List<Widget>? headerWidgets;
    if (header != null) {
      headerWidgets = [
        header!,
        Divider(
          thickness: context.sizes.spaceXS,
          height: context.sizes.spaceM,
        ),
      ];
    }

    var quoteTextWidgets = <Widget>[
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
          if (button != null) button!,
        ],
      ),
    ];

    Widget? tagsWidget;
    if (showTags && quote.tags.isNotEmpty) {
      tagsWidget = QuoteTagList(
        tags: quote.tags,
        maxTagsToShow: maxTagsToShow,
        onTagPressed: onTagPressed,
      );
    }

    return Card(
      elevation: 8.0,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (headerWidgets != null) ...headerWidgets,
            ...quoteTextWidgets,
            if (tagsWidget != null) ...[
              SizedBox(height: context.sizes.spaceM),
              tagsWidget,
            ],
            if (trailing != null) ...[
              SizedBox(height: context.sizes.spaceM),
              trailing!,
            ]
          ],
        ),
      ),
    );
  }
}

//TODO should we just use dynamic instead of this?
class WidgetOrQuote {
  final Widget? widget;
  final Quote? quote;

  const WidgetOrQuote({
    this.widget,
    this.quote,
  });
}

class DynamicQuoteCard extends StatelessWidget {
  final TextStyle? quoteTextStyle;
  final TextStyle? authorTextStyle;
  final WidgetOrQuote Function(BuildContext context) contentBuilder;

  final Widget? header;
  final Widget? button;
  final Widget? trailing;

  //defaults to theme.insets.paddingM
  final EdgeInsets? padding;

  final bool showTags;
  //max number of tags to show, if there are more there will be a button to show all
  //if -1 show all tags by default
  final int maxTagsToShow;
  final void Function(String tag)? onTagPressed;

  const DynamicQuoteCard({
    Key? key,
    required this.contentBuilder,
    this.quoteTextStyle,
    this.authorTextStyle,
    this.header,
    this.button,
    this.trailing,
    this.padding,
    this.showTags = true,
    this.maxTagsToShow = 4,
    this.onTagPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var padding = this.padding ?? context.insets.paddingM;

    List<Widget>? headerWidgets;
    if (header != null) {
      headerWidgets = [
        Align(alignment: Alignment.centerLeft, child: header!),
        Divider(
          thickness: context.sizes.spaceXS,
          height: context.sizes.spaceL,
        ),
      ];
    }

    Widget contentWidget = Builder(
      builder: (context) {
        var widgetOrQuote = contentBuilder(context);
        if (widgetOrQuote.widget != null) {
          return widgetOrQuote.widget!;
        } else if (widgetOrQuote.quote != null) {
          var quote = widgetOrQuote.quote!;

          Widget buttonWidget = button ?? QuoteFavoriteButton(quote: quote);

          var quoteTextWidgets = <Widget>[
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
                buttonWidget,
              ],
            ),
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
            children: [
              ...quoteTextWidgets,
              if (tagsWidget != null) ...[
                SizedBox(height: context.sizes.spaceM),
                tagsWidget,
              ],
            ],
          );
        } else {
          return Container();
        }
      },
    );

    return Card(
      elevation: 8.0,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (headerWidgets != null) ...headerWidgets,
            contentWidget,
            if (trailing != null) ...[
              SizedBox(height: context.sizes.spaceM),
              trailing!,
            ]
          ],
        ),
      ),
    );
  }
}
