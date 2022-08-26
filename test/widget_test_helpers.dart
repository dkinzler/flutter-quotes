import 'package:flutter/material.dart';
import 'package:flutter_quotes/theme/theme.dart';

/*
This is a convenience method for widget tests, since most widgets
need a Theme/Material/MediaQuery/... ancestor to actually be able to build.
*/
Widget buildWidget(Widget widget) {
  return MaterialApp(
    builder: AppTheme.appBuilderTest,
    home: Scaffold(
      body: widget,
    ),
  );
}
