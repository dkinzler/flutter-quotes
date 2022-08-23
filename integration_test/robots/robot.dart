import 'package:flutter/widgets.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class Robot {
  final WidgetTester tester;
  //must be provided to be able to take screenshots
  final IntegrationTestWidgetsFlutterBinding? binding;
  //a short name for the current test, might e.g. be used as a folder name for screenshots
  final String? testName;
  //how long to wait after an action, e.g. after entering text or pressing a button
  Duration? actionDelay;

  Robot({
    required this.tester,
    this.testName,
    this.actionDelay,
    this.binding,
  });

  Future<void> _applyActionDelay() async {
    if (actionDelay != null) {
      await Future.delayed(actionDelay!);
    }
  }

  //for convenience can either pass an AppKey value, a Key or a widget Type
  Finder _find(dynamic d, {bool skipOffstage = true}) {
    if (d is AppKey) {
      return find.byKey(ValueKey<AppKey>(d), skipOffstage: skipOffstage);
    } else if (d is Key) {
      return find.byKey(d, skipOffstage: skipOffstage);
    } else if (d is Type) {
      return find.byType(d, skipOffstage: skipOffstage);
    } else if (d is Finder) {
      return d;
    } else {
      throw Exception('findByKeyOrType: key and type cannot both be null');
    }
  }

  Future<void> enterText(dynamic finder, String text,
      {bool addDelay = true}) async {
    //tap will already ensure that the widget is visible, so we don't need to explicitely call ensureVisible() here
    await tap(finder, addDelay: false);
    await tester.enterText(_find(finder), text);
    await tester.pumpAndSettle();
    if (addDelay) {
      await _applyActionDelay();
    }
  }

  Future<void> tap(
    dynamic finder, {
    bool addDelay = true,
    bool ensureVisible = true,
    //if multiple elements are found for the given finder, match the one at the given index
    int? matchAtIndex,
  }) async {
    //make sure the widget is visible
    if (ensureVisible) {
      var f = _find(finder, skipOffstage: false);
      if (matchAtIndex != null) {
        f = f.at(matchAtIndex);
      }
      await tester.ensureVisible(f);
    }
    await tester.pumpAndSettle();
    await tester.tap(
        matchAtIndex != null ? _find(finder).at(matchAtIndex) : _find(finder));
    await tester.pumpAndSettle();
    if (addDelay) {
      await _applyActionDelay();
    }
  }

  Future<void> ensureVisible(dynamic finder) async {
    await tester.ensureVisible(_find(finder, skipOffstage: false));
    await tester.pumpAndSettle();
    await _applyActionDelay();
  }

  Future<void> verifyWidgetIsShown(dynamic finder) async {
    expect(_find(finder), findsOneWidget);
  }

  Future<void> verifyTextIsShown(String text, {dynamic ancestor}) async {
    var finder = find.textContaining(text);
    if (ancestor != null) {
      finder = find.descendant(of: _find(ancestor), matching: finder);
    }
    expect(finder, findsOneWidget);
  }

  Future<void> scrollUntilVisible(
    dynamic finder, {
    double delta = 200,
    Duration duration = const Duration(milliseconds: 50),
    dynamic scrollableFinder,
  }) async {
    await tester.scrollUntilVisible(
      _find(finder),
      delta,
      scrollable: scrollableFinder != null ? _find(scrollableFinder) : null,
      duration: duration,
    );
    await tester.pumpAndSettle();
    await _applyActionDelay();
  }

  bool isWidgetShown(dynamic finder) {
    try {
      expect(_find(finder), findsOneWidget);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> goBack() async {
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _applyActionDelay();
  }

  //if no name is given for a screenshot, this number will be used and incremented afterwards
  int _screenshotCount = 0;
  bool _surfaceConverted = false;

  //can be used to globally turn on/off screenshot taking
  //code can still contain the calls to takeScreenshot, but nothing will happen
  static bool _screenshotsEnabled = true;

  static void enableScreenshots() => _screenshotsEnabled = true;

  static void disableScreenshots() => _screenshotsEnabled = false;

  Future<void> takeScreenshot({String? name}) async {
    if (binding == null || !_screenshotsEnabled) {
      return;
    }
    if (name == null) {
      name = _screenshotCount.toString();
      _screenshotCount++;
    }

    var fullName = testName == null ? name : '$testName/$name';

    if (!_surfaceConverted) {
      await binding!.convertFlutterSurfaceToImage();
      _surfaceConverted = true;
    }

    await tester.pumpAndSettle();
    await binding!.takeScreenshot(fullName);
  }
}
