import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/explore/favorites/favorite_widget.dart';
import 'package:flutter_quotes/explore/random/random_cubit.dart';
import 'package:flutter_quotes/explore/random/random_widget.dart';
import 'package:flutter_quotes/quote/repository/repository.dart';
import 'package:flutter_quotes/theme/theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RandomCubit(quoteRepository: context.read<QuoteRepository>()),
      child: const _ExploreScreenWidget(),
    );
  }
}

class _ExploreScreenWidget extends StatelessWidget {
  const _ExploreScreenWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isMobile = context.layout == Layout.mobile;
    var padding = isMobile ? context.insets.paddingM : context.insets.paddingL;

    //on mobile show just a single favorite and a single random quote
    if (isMobile) {
      return SingleChildScrollView(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const FavoritesWidget(numQuotes: 1),
              SizedBox(height: context.sizes.spaceM),
              const RandomQuoteWidget(
                numQuotes: 1,
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: padding,
        child: Column(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              return FavoritesWidget(
                numQuotes: _computeColumns(
                  constraints,
                  scale: context.appTheme.scale,
                ),
              );
            }),
            SizedBox(height: context.sizes.spaceM),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                var scale = context.appTheme.scale;
                var numColumns = _computeColumns(constraints, scale: scale);
                var numRows = _computeRows(constraints, scale: scale);
                return RandomQuoteWidget(
                  numQuotes: numRows * numColumns,
                  numColumns: numColumns,
                  expand: true,
                );
              }),
            ),
          ],
        ),
      );
    }
  }

  int _computeColumns(BoxConstraints constraints, {double scale = 1.0}) {
    var numColumns = 1;
    if (constraints.maxWidth.isFinite) {
      numColumns = max(1, (constraints.maxWidth / scale / 400).floor());
    }
    return numColumns;
  }

  int _computeRows(BoxConstraints constraints, {double scale = 1.0}) {
    var numRows = 1;
    if (constraints.maxHeight.isFinite) {
      numRows = max(1, (constraints.maxHeight / scale / 180).floor());
    }
    return numRows;
  }
}
