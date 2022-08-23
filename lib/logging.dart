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

void initLogging(Logger logger, {bool setOnError = true}) {
  logging.Logger.root.onRecord.listen((record) => logger.log(record));
  if (setOnError) {
    FlutterError.onError = logger.logFlutterError;
  }
}

/*
Interface for classes that want to handle the log messages and errors of the application.
For this sample app we only have one implementing class, ConsoleLogger, that just prints the log messages and errors to console.
For a production app we could use an implementation that sends the logs and errors to a service
like Sentry or FirebaseCrashlytics.
*/
abstract class Logger {
  //used for application logs, i.e. blocs/cubits/repositories/... that use the logging package
  void log(logging.LogRecord record);

  //passed to runZoneGuarded.onError to log any otherwise uncaught errors
  void logError(Object error, {StackTrace? stackTrace});

  //used to log flutter errors by setting FlutterError.onError to this function
  void logFlutterError(FlutterErrorDetails details);
}

//Simple implementation of the Logger interface that just prints any log and error messages to console.
class ConsoleLogger extends Logger {
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
  void logError(Object error, {StackTrace? stackTrace}) {
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
