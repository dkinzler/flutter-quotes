import 'package:flutter/material.dart';
import 'package:flutter_quotes/app.dart';
import 'package:flutter_quotes/app_controller.dart';
import 'package:flutter_quotes/logging.dart';
import 'package:flutter_quotes/util/mock_hydrated_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/*
Separate main function for integration test, since e.g. setting a custom
Flutter.onError function will cause issues.
We also set up Hive to use mock storage and not actually create any files that we would have to clean up after the tests.
*/
Future<void> mainIntegrationTest() async {
  var logger = ConsoleLogger();
  WidgetsFlutterBinding.ensureInitialized();
  initLogging(logger, setOnError: false);
  HydratedBloc.storage = MockStorage();
  runApp(App(
    appController: AppController(useMockStorage: true),
  ));
}
