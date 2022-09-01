import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quotes/app.dart';
import 'package:flutter_quotes/app_controller.dart';
import 'package:flutter_quotes/logging.dart';
import 'package:flutter_quotes/util/mock_hydrated_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

//bootstrap sets up and runs the app with the given configuration
Future<void> bootstrap(AppConfig config) async {
  var logger = config.logger;

  Future<void> runFunc() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (logger != null) {
      logger.initLogging();
    }

    //init storage
    if (!config.useMockStorage) {
      await Hive.initFlutter(storageSubDir);
    }
    HydratedBloc.storage =
        config.useMockStorage ? MockStorage() : await buildHydratedStorage();

    AppController? appController =
        config.useMockStorage ? AppController(useMockStorage: true) : null;
    Widget app = config.appBuilder != null
        ? config.appBuilder!(appController)
        : App(
            appController: appController,
          );
    runApp(app);
  }

  if (config.runInZone) {
    return runZonedGuarded<Future<void>>(
      runFunc,
      logger != null ? logger.logError : (error, stack) {},
    );
  } else {
    return runFunc();
  }
}

class AppConfig extends Equatable {
  //the logger to use and init
  final Logger? logger;
  //will use mock storage for repositories and HydratedBlocs/HydratedCubits
  //this is useful for testing, because no files will actually be created and thus we don't have to perform any cleanup up after the tests
  final bool useMockStorage;
  //whether to set up and run the app in a new zone uses the runZonedGuarded function
  final bool runInZone;
  final Widget Function(AppController?)? appBuilder;

  const AppConfig({
    this.logger,
    this.useMockStorage = false,
    this.runInZone = true,
    this.appBuilder,
  });

  @override
  List<Object?> get props => [logger, useMockStorage, runInZone, appBuilder];
}

//TODO let the user choose a storage directory in the app settings, use this as default
const String storageSubDir = 'flutter-quotes';

Future<HydratedStorage> buildHydratedStorage() async {
  return HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getStorageDirectory(),
  );
}

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
