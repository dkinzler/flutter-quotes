import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'insets.dart';
import 'layout.dart';
import 'sizes.dart';

final ThemeData baseTheme = ThemeData.from(
  colorScheme: colorScheme,
);

final ColorScheme colorScheme = ColorScheme.fromSwatch(
  primarySwatch: MaterialColor(
    const Color.fromARGB(0xFF, 0x46, 0x70, 0x88).value, const <int, Color>{
      50: Color.fromARGB(0xFF, 0x78, 0xA2, 0xBA),
      100: Color.fromARGB(0xFF, 0x6B, 0x98, 0xB3),
      200: Color.fromARGB(0xFF, 0x5D, 0x8F, 0xAC),
      300: Color.fromARGB(0xFF, 0x53, 0x85, 0xA2),
      400: Color.fromARGB(0xFF, 0x4C, 0x7A, 0x94),
      500: Color.fromARGB(0xFF, 0x46, 0x70, 0x88),
      600: Color.fromARGB(0xFF, 0x3E, 0x64, 0x79),
      700: Color.fromARGB(0xFF, 0x37, 0x59, 0x6C),
      800: Color.fromARGB(0xFF, 0x31, 0x4D, 0x5E),
      900: Color.fromARGB(0xFF, 0x2A, 0x42, 0x51),
    },
  ),
  //accentColor: const Color.fromARGB(0xFF, 0xED, 0x98, 0x2A),
  //accentColor: const Color.fromARGB(0xFF, 0x83, 0x61, 0x78),
  //accentColor: const Color.fromARGB(0xFF, 0xB8, 0x94, 0xAC),
  //accentColor: const Color.fromARGB(0xFF, 0xB4, 0xDE, 0xF9),
  accentColor: const Color.fromARGB(0xFF, 0xE6, 0xF4, 0xF1),
  backgroundColor: Colors.grey.shade700, 
  brightness: Brightness.dark,
);

class AppThemeData extends Equatable {
  final headerColor = const Color.fromARGB(255, 51,85,110);
  final scaffoldBackgroundColor = Colors.grey.shade500;

  final Layout layout; 

  final double scale;
  final double fontSizeFactor;

  final Sizes sizes;
  final Insets insets;

  AppThemeData({
    required this.layout,
    this.scale = 1.0,
    this.fontSizeFactor = 1.0,
  }) : sizes = Sizes(scale: scale),
    insets = Insets(scale: scale);

  @override
  List<Object?> get props => [
    layout,
    scale,
    fontSizeFactor,
    sizes,
    insets,
  ];

  final CardTheme cardTheme = CardTheme(
    color: Colors.blueGrey.shade700,
  );

  ThemeData themeDataFrom(ThemeData base) {
    return base.copyWith(
      textTheme:  base.textTheme.apply(fontSizeFactor: fontSizeFactor),
      primaryTextTheme: base.primaryTextTheme.apply(fontSizeFactor: fontSizeFactor),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardTheme: cardTheme,
    );
  }

  AppThemeData copyWith({
    Layout? layout,
    double? scale,
    double? fontSizeFactor,
  }) {
    return AppThemeData(
      layout: layout ?? this.layout,
      scale: scale ?? this.scale,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
    );
  }
}

/*
AppTheme should be inserted below MaterialApp in the widget tree, by passing AppTheme.appBuilder to the builder argument of the MaterialApp constructor.
This ensures that a MediaQuery and Theme ancestor can be found.

Furthermore we need a Theme ancestor to make fontScaling work.
When a ThemeData object is created (e.g. with the ThemeData.from constructor), the contained TextStyles do not yet contain geometry data (font size, weight, ...).
These are added based on localization, whenever the Theme.of method is called.
Without fontSize set on the TextStyles we cannot apply font scaling (TextStyle.apply will throw an exception if fontSize is null, but a fontScaleFactor != 1.0 is provided).
To fix this, AppTheme inserts another Theme widget, which has font scaling applied to Theme.of(context).
*/
class AppTheme extends StatelessWidget {
  final Widget child;

  const AppTheme({
    Key? key,
    required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var layout = Layout.fromSize(size);
    var theme = Theme.of(context);
    var appThemeData = AppThemeData(
      layout: layout,
    );
    return _InheritedAppTheme(
      appThemeData: appThemeData,
      child: Theme(
        data: appThemeData.themeDataFrom(theme),
        child: child,
      ),
    );
  }

  static AppThemeData of(BuildContext context) {
    var widget = context.dependOnInheritedWidgetOfExactType<_InheritedAppTheme>();
    if(widget == null) {
      throw Exception("No AppTheme found in context");
    }
    return widget.appThemeData;
  }

  static Widget appBuilder(BuildContext context, Widget? child) {
    if(child == null) {
      throw Exception('AppTheme: no child widget provided to appBuilder method');
    }
    return AppTheme(
      child: child,
    );
  }
}

class _InheritedAppTheme extends InheritedWidget {

  final AppThemeData appThemeData;

  const _InheritedAppTheme({Key? key, required this.appThemeData, required Widget child})
   : super(key : key, child: child);
  
  @override
  bool updateShouldNotify(covariant _InheritedAppTheme oldWidget) {
    return appThemeData != oldWidget.appThemeData;
  }
}

extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  AppThemeData get appTheme => AppTheme.of(this);
  Layout get layout => appTheme.layout;
  Sizes get sizes => appTheme.sizes;
  Insets get insets => appTheme.insets;
}
