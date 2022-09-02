import 'dart:async';
import 'package:flutter_quotes/bootstrap.dart';
import 'logging.dart';

Future<void> main() async {
  return bootstrap(AppConfig(
    logger: ConsoleLogger(),
    useMockStorage: false,
  ));
}
