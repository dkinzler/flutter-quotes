import 'package:flutter/material.dart';
import 'package:flutter_sample/explore/random_widget.dart';
import 'package:flutter_sample/theme/theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.insets.paddingL,
      child: Center(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600 * context.appTheme.scale),
              child: const RandomQuoteWidget(),
            ),
          ],
        ),
      ),
    );
  }
}