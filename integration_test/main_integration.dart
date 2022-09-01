import 'package:flutter_quotes/app_controller.dart';
import 'package:flutter_quotes/bootstrap.dart';
import 'package:flutter_quotes/logging.dart';

/*
Separate main function for integration test, since e.g. setting a custom
Flutter.onError function will cause issues.
We also set up Hive to use mock storage and not actually create any files that we would have to clean up after the tests.
*/
Future<void> mainIntegrationTest() async {
  return bootstrap(
    AppConfig(
      logger: ConsoleLogger(setFlutterOnError: false),
      useMockStorage: true,
      runInZone: false,
    ),
  );
}
