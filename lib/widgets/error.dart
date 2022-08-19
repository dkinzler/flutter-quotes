import 'package:flutter/material.dart';
import 'package:flutter_quotes/theme/app_theme.dart';

class ErrorText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  //if null theme.errorColor is used
  final Color? textColor;

  const ErrorText(
      {Key? key, required this.text, this.textStyle, this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textColor = this.textColor ?? context.theme.errorColor;
    var textStyle = this.textStyle ?? context.theme.textTheme.bodyLarge;
    textStyle = textStyle?.apply(color: textColor);
    return Text(
      text,
      style: textStyle,
    );
  }
}

class ErrorRetryWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  //if null theme.errorColor is used
  final Color? textColor;
  final String buttonText;
  final void Function() onPressed;

  final double? horizontalSpace;

  final bool showErrorIcon;

  const ErrorRetryWidget({
    Key? key,
    this.text = 'Ups, something went wrong.',
    this.textStyle,
    this.textColor,
    this.buttonText = 'Try again',
    this.horizontalSpace,
    required this.onPressed,
    this.showErrorIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var ts = textStyle ?? context.theme.textTheme.bodyLarge;
    ts = ts?.apply(color: textColor);

    var hs = horizontalSpace ?? context.sizes.spaceM;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showErrorIcon)
          Icon(
            Icons.error,
            size: context.sizes.scaled(64),
          ),
        SizedBox(height: hs),
        Text(
          'Ups, something went wrong',
          style: ts,
        ),
        SizedBox(height: hs),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      ],
    );
  }
}
