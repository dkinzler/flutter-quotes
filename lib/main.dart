import 'dart:async';
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
      runApp(const App());
      //TODO set error logging function here, also set FlutterError.onError
    },
    (error, stack) {},
  );
}
