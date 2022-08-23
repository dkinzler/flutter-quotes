import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'logging.dart';
import 'app.dart';

Future<void> main() async {
  var logger = ConsoleLogger();
  //runZoneGuarded makes it possible to intercept any uncaught errors and log them
  return runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initLogging(logger);
      await Hive.initFlutter('flutter-quotes');
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : Directory(p.join((await getApplicationDocumentsDirectory()).path,
                'flutter-quotes')),
      );
      runApp(const App());
    },
    (error, stack) => logger.logError(error, stackTrace: stack),
  );
}

/*
Separate main function for integration test, since e.g. setting a custom
Flutter.onError function will cause issues.
*/
Future<void> mainIntegrationTest() async {
  var logger = ConsoleLogger();
  WidgetsFlutterBinding.ensureInitialized();
  initLogging(logger, setOnError: false);
  if (!kIsWeb) {
    Hive.init(p.join((await getTemporaryDirectory()).path, 'flutter-quotes'));
  }
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : Directory(
            p.join((await getTemporaryDirectory()).path, 'flutter-quotes')),
  );
  runApp(const App());
}
