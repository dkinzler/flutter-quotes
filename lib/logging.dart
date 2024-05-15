import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart' as logging;

/*
How logging works in this app
-----------------------------

Application classes like blocs/cubits/services/repositories/... can create their
own Logger instance (from the logging package) to log messages/warnings/errors.

Example:
import 'package:logging/loggin.dart' as logging;

class ServiceX {
  final _log = logging.Logger('ServiceX')

  void someMethod() {
    try {
      ...
    } catch(e) {
      _log.warning('ups, something went wrong', e)
    }
  }
}

All log messages, errors from the flutter framework and any other uncaught errors
can be processed by using a class implementing the Logger interface (see below for more info).
Depending on the implementation, the logs and errors could e.g. just be printed to console
or sent to a cloud service like Sentry.
*/

void initLogging(Logger logger, {bool setOnError = true}) {}

/*
Interface for classes that want to handle the log messages and errors of the application.
For this sample app we only have one implementing class, ConsoleLogger, that just prints the log messages and errors to console.
For a production app we could use an implementation that sends the logs and errors to a service
like Sentry or FirebaseCrashlytics.
*/
abstract class Logger {
  final bool setFlutterOnError;

  Logger({
    //turn of using FlutterError.onError, it is e.g. not compatible with integration_test
    this.setFlutterOnError = true,
  });

  //used for application logs, i.e. blocs/cubits/repositories/... that use the logging package
  void log(logging.LogRecord record);

  //catch any otherwise uncaught errors by setting PlatformDispatcher.instance.onError to this function
  void logError(Object error, StackTrace? stackTrace);

  //used to log flutter errors by setting FlutterError.onError to this function
  void logFlutterError(FlutterErrorDetails details);

  StreamSubscription? _loggingSubscription;

  void initLogging() {
    PlatformDispatcher.instance.onError = (error, stack) {
      logError(error, stack);
      return true;
    };
    _loggingSubscription =
        logging.Logger.root.onRecord.listen((record) => log(record));
    if (setFlutterOnError) {
      FlutterError.onError = logFlutterError;
    }
  }

  Future<void> close() async {
    return _loggingSubscription?.cancel();
  }
}

class ConsoleLogger extends Logger {
  ConsoleLogger({super.setFlutterOnError = true});

  @override
  void log(logging.LogRecord record) {
    print('''
      ${record.level.name} ${record.time}
      ${record.loggerName}: ${record.message}
      Error: ${record.error}
      StackTrace:
      ${record.stackTrace}
    ''');
  }

  @override
  void logError(Object error, StackTrace? stackTrace) {
    print('''
      Error: $error,
      StackTrace:
      $stackTrace
    ''');
  }

  @override
  void logFlutterError(FlutterErrorDetails details) {
    FlutterError.presentError(details);
  }
}
