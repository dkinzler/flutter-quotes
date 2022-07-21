import 'dart:async';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'logging.dart';
import 'app.dart';

Future<void> main() async {
  return runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initLogging();
      await Hive.initFlutter();
      runApp(DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => App(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
        ),
      ));
      //TODO set error logging function here, also set FlutterError.onError
    },
    (error, stack) {},
  );
}
