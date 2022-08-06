import 'package:flutter/material.dart';
import 'package:flutter_sample/theme/theme.dart';

class CustomCard extends StatelessWidget {
  final Widget? header;
  final Widget content;
  final Widget? trailing;

  //defaults to theme.insets.paddingM
  final EdgeInsets? padding;

  const CustomCard({
    Key? key,
    this.header,
    required this.content,
    this.trailing,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var padding = this.padding ?? context.insets.paddingM;

    List<Widget>? headerWidgets;
    if (header != null) {
      headerWidgets = [
        Align(
          alignment: Alignment.centerLeft,
          child: header!,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.3,
            child: Divider(
              thickness: context.sizes.spaceXS,
              height: context.sizes.spaceL,
              color: context.theme.colorScheme.primary,
            ),
          ),
        ),
      ];
    }

    return Card(
      elevation: 8.0,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (headerWidgets != null) ...headerWidgets,
            content,
            if (trailing != null) ...[
              SizedBox(height: context.sizes.spaceM),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
