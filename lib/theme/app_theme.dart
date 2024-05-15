import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/settings/settings_cubit.dart';
import 'insets.dart';
import 'layout.dart';
import 'sizes.dart';

ThemeData get baseThemeDark => ThemeData.from(
      colorScheme: const ColorScheme.dark(),
    );

ThemeData get baseThemeLight => ThemeData.from(
      colorScheme: const ColorScheme.light(),
    );

/*
AppThemeData defines all the custom theme data of the app.
It is inserted into the widget tree using the AppTheme widget and can be accessed with
"AppTheme.of(context)" or simply "context.appTheme".

This is the place to define icon themes, card themes, paddings, size constants, etc
that can be used across the app.
Some of elements are grouped into separate classes, e.g. there is a class Insets that 
contains predefined paddings and a class Sizes that contains predefined size constants.
To make things consistent and easy to change across the entire app, always try
to use themes and constants from AppThemeData instead of using hard-coded values.

Some AppThemeData properties can be directly accessed using a BuildContext,
e.g. "context.insets.paddingL".
To add this behaviour for more properties, simply edit the AppThemeContext extension on BuildContext below.
*/
class AppThemeData extends Equatable {
  // device/screen size type
  // can be used to build adaptive layouts, e.g. a list on mobile
  // and a grid with multiple columns on larger screens like a tablet or desktop
  final Layout layout;

  // UI scaling factor that is applied to sizes, paddings, text themes, etc.
  // Scale can be changed by the user in the app settings.
  final double scale;

  // contains different size constants that are scaled by "scale"
  // can e.g. be used to insert whitespace in rows or columns using a SizedBox
  final Sizes sizes;

  // contains different paddings that are scaled by "scale"
  final Insets insets;

  AppThemeData({required this.layout, this.scale = 1.0})
      : sizes = Sizes(scale: scale),
        insets = Insets(scale: scale);

  @override
  List<Object?> get props => [
        layout,
        scale,
        sizes,
        insets,
      ];

  ThemeData themeDataFrom(ThemeData base) {
    return base.copyWith(
      textTheme: base.textTheme.apply(fontSizeFactor: scale),
      primaryTextTheme: base.primaryTextTheme.apply(fontSizeFactor: scale),
      // set any other theme properties like iconTheme or cardTheme here
    );
  }

  AppThemeData copyWith({
    Layout? layout,
    bool? darkMode,
    double? scale,
  }) {
    return AppThemeData(
      layout: layout ?? this.layout,
      scale: scale ?? this.scale,
    );
  }
}

/*
AppTheme makes an AppThemeData instance available to the widget tree.
It depends on the screen size (using MediaQuery) and the app settings. Whenever one of these
dependencies change, AppTheme automatically rebuilds a new AppThemeData instance.

AppTheme should be inserted below MaterialApp in the widget tree, by passing AppTheme.appBuilder to the builder argument of the MaterialApp constructor.
This ensures that a MediaQuery and Theme ancestor can be found.
We need a Theme ancestor to make font scaling work.
When a ThemeData object is created (e.g. with the ThemeData.from constructor), the contained TextStyles do not yet contain geometry data (font size, weight, ...).
These are added based on localization, whenever the Theme.of method is called.
Without fontSize set on the TextStyles we cannot apply font scaling (TextStyle.apply will throw an exception if fontSize is null, but a fontScaleFactor != 1.0 is provided).
To work around this, AppTheme inserts another Theme widget, which has font scaling applied to Theme.of(context).
*/
class AppTheme extends StatelessWidget {
  final Widget child;
  final bool listenToSettings;

  const AppTheme({
    Key? key,
    required this.child,
    // set to false for tests so they don't have to create a SettingsCubit
    this.listenToSettings = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);

    var size = mediaQueryData.size;
    var layout = Layout.fromSize(size);

    // if a textScaleFactor other than 1.0 is set we will use this factor
    // instead of the one defined in the app settings
    // textScaleFactor might not be 1.0 if e.g. the user changes OS wide scaling settings
    var textScaleFactor = mediaQueryData.textScaleFactor;
    double settingsScale = 1.0;
    if (listenToSettings) {
      settingsScale =
          context.select<SettingsCubit, double>((c) => c.state.uiScale);
    }
    var scale = textScaleFactor == 1.0 ? settingsScale : textScaleFactor;

    var theme = Theme.of(context);
    var appThemeData = AppThemeData(
      layout: layout,
      scale: scale,
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
    var widget =
        context.dependOnInheritedWidgetOfExactType<_InheritedAppTheme>();
    if (widget == null) {
      throw Exception("No AppTheme found in context");
    }
    return widget.appThemeData;
  }

  static Widget appBuilder(BuildContext context, Widget? child) {
    if (child == null) {
      throw Exception(
          'AppTheme: no child widget provided to appBuilder method');
    }
    return AppTheme(
      child: child,
    );
  }

  // eliminates the dependency on SettingsCubit, use for widget tests
  static Widget appBuilderTest(BuildContext context, Widget? child) {
    if (child == null) {
      throw Exception(
          'AppTheme: no child widget provided to appBuilder method');
    }
    return AppTheme(
      listenToSettings: false,
      child: child,
    );
  }
}

class _InheritedAppTheme extends InheritedWidget {
  final AppThemeData appThemeData;

  const _InheritedAppTheme(
      {Key? key, required this.appThemeData, required Widget child})
      : super(key: key, child: child);

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
