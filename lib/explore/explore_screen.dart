import 'package:flutter/material.dart';
import 'package:flutter_sample/explore/favorite_widget.dart';
import 'package:flutter_sample/explore/random_widget.dart';
import 'package:flutter_sample/theme/theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isMobile = context.layout == Layout.mobile;
    var padding = isMobile ? context.insets.paddingM : context.insets.paddingL;

    return Center(
      child: Padding(
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: 600 * context.appTheme.scale),
                child: const RandomQuoteWidget(),
              ),
              SizedBox(height: context.sizes.spaceM),
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: 600 * context.appTheme.scale),
                child: const FavoriteWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
