import 'package:flutter/material.dart';
import 'package:flutter_quotes/explore/favorites/favorite_widget.dart';
import 'package:flutter_quotes/explore/random/random_widget.dart';
import 'package:flutter_quotes/theme/theme.dart';

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
                    BoxConstraints(maxWidth: context.sizes.scaled(600)),
                child: const RandomQuoteWidget(),
              ),
              SizedBox(height: context.sizes.spaceM),
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: context.sizes.scaled(600)),
                child: const FavoriteWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
