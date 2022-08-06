import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'logging.dart';
import 'app.dart';

Future<void> main() async {
  var logger = ConsoleLogger();
  //runZoneGuarded makes it possible to intercept any uncaught errors and log them
  return runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initLogging(logger);
      await Hive.initFlutter();
      final storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getApplicationDocumentsDirectory(),
      );
      HydratedBlocOverrides.runZoned(
        () => runApp(const App()),
        storage: storage,
      );
    },
    (error, stack) => logger.logError(error, stackTrace: stack),
  );
}
