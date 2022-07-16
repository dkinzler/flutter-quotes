import 'package:flutter/widgets.dart';
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
    if(actionDelay != null) {
      await Future.delayed(actionDelay!);
    }
  }

  Finder findByKey(Key key, {bool skipOffstage = true}) {
    return find.byKey(key, skipOffstage: skipOffstage);
  }

  Future<void> enterText(Key key, String text, {bool addDelay = true}) async {
    await tap(key, addDelay: false);
    await tester.enterText(findByKey(key), text);
    await tester.pumpAndSettle();
    if(addDelay) {
      await _applyActionDelay();
    }
  } 

  Future<void> tap(Key key, {bool addDelay = true}) async {
    //make sure the widget is visible
    await tester.ensureVisible(findByKey(key, skipOffstage: false));
    await tester.pumpAndSettle();
    await tester.tap(findByKey(key));
    await tester.pumpAndSettle();
    if(addDelay) {
      await _applyActionDelay();
    }
  }

  Future<void> ensureVisible(Key key) async {
    await tester.ensureVisible(findByKey(key, skipOffstage: false));
    await tester.pumpAndSettle();
    await _applyActionDelay();
  }

  Future<void> verifyWidgetIsShown({Key? key, Type? type}) async {
    if(key != null) {
      expect(findByKey(key), findsOneWidget);
    } else if(type != null) {
      expect(find.byType(type), findsOneWidget);
    }
  }

  Future<void> verifyTextIsShown(String text, {Type? ancestor}) async {
    var finder = find.textContaining(text);
    if(ancestor != null) {
      finder = find.descendant(of: find.byType(ancestor), matching: finder);
    }
    expect(finder, findsOneWidget);
  }

  //if no name is given for a screenshot, this number will be used and incremented afterwards
  int _screenshotCount = 0;
  bool _surfaceConverted = false;
  //can be used to turn off screenshot taking
  //code can still contain the calls to takeScreenshot, but nothing will happen
  bool screenshotsEnabled = true;

  void enableScreenshots() => screenshotsEnabled = true;

  void disableScreenshots() => screenshotsEnabled = false;

  Future<void> takeScreenshot({String? name}) async {
    if(binding == null || !screenshotsEnabled) {
      return;
    }
    if(name == null) {
      name = _screenshotCount.toString();
      _screenshotCount++;
    }

    var fullName = testName == null ? name : '$testName/$name';

    if(!_surfaceConverted) {
      await binding!.convertFlutterSurfaceToImage();
      _surfaceConverted = true;
    }

    await tester.pumpAndSettle();
    await binding!.takeScreenshot(fullName);
  }
}
