import 'package:flutter/material.dart';
import 'package:flutter_quotes/theme/theme.dart';

class Header extends StatelessWidget {
  final String text;
  final double underlineWidthFactor;
  final Widget? trailing;

  const Header(
      {Key? key,
      required this.text,
      this.underlineWidthFactor = 0.3,
      this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: context.theme.textTheme.headlineSmall,
              ),
              FractionallySizedBox(
                widthFactor: underlineWidthFactor,
                child: Divider(
                  thickness: context.sizes.spaceXS,
                  height: context.sizes.spaceL,
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
