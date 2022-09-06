import 'package:flutter/material.dart';
import 'package:flutter_quotes/theme/theme.dart';

class Header extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const Header({
    Key? key,
    required this.text,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget header = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.theme.colorScheme.primary,
            width: 4.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: context.theme.textTheme.headlineSmall,
        ),
      ),
    );

    if (trailing == null) {
      return header;
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: header,
          ),
          trailing!,
        ],
      );
    }
  }
}
