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
      await Hive.initFlutter(storageSubDir);
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getStorageDirectory(),
      );
      runApp(const App());
    },
    (error, stack) => logger.logError(error, stackTrace: stack),
  );
}

const String storageSubDir = 'flutter-quotes';

Future<Directory> getStorageDirectory() async {
  var appDir = await getApplicationDocumentsDirectory();
  var path = p.join(appDir.path, storageSubDir);
  return Directory(path);
}

Future<Directory> getTemporaryStorageDirectory() async {
  var appDir = await getTemporaryDirectory();
  var path = p.join(appDir.path, storageSubDir);
  return Directory(path);
}

/*
Separate main function for integration test, since e.g. setting a custom
Flutter.onError function will cause issues.
*/
Future<void> mainIntegrationTest() async {
  var logger = ConsoleLogger();
  WidgetsFlutterBinding.ensureInitialized();
  initLogging(logger, setOnError: false);
  Directory? storageDirectory;
  if (!kIsWeb) {
    storageDirectory = await getTemporaryStorageDirectory();
    Hive.init(storageDirectory.path);
  }
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb ? HydratedStorage.webStorageDirectory : storageDirectory!,
  );
  runApp(const App());
}
