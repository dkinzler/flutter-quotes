import 'dart:async';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quotes/app.dart';
import 'package:flutter_quotes/logging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'main.dart' as m;

Future<void> main() async {
  var logger = ConsoleLogger();
  return runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initLogging(logger);
      await Hive.initFlutter(m.storageSubDir);
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await m.getStorageDirectory(),
      );
      runApp(DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => App(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
        ),
      ));
    },
    (error, stack) => logger.logError(error, stackTrace: stack),
  );
}
