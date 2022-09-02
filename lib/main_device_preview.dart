import 'dart:async';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quotes/app.dart';
import 'package:flutter_quotes/bootstrap.dart';
import 'package:flutter_quotes/logging.dart';

/*
Use the device_preview package to easily check how the app would look on different devices and screen sizes.
Run with "flutter run -t lib/main_device_preview.dart"
*/
Future<void> main() async {
  return bootstrap(AppConfig(
    logger: ConsoleLogger(),
    useMockStorage: false,
    appBuilder: (ac) => DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => App(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        appController: ac,
      ),
    ),
  ));
}
