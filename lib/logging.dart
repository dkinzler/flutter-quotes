import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/*
How logging works in this app
-----------------------------

Classes like Blocs/Cubits/Repositories/Api clients 
can create their own Logger instances to log messages/warnings/errors.

Example:
final Logger _log = Logger('SomeClass')
_log.warning('got an error', e)

Log records from all Logger instances can be observed using the
onRecord stream of the root Logger instance.
In production we could e.g. send these log records to a
service like Firebase Crashlytics or Sentry.
*/

void initLogging() {
  //print log messages in debug mode
  if(kDebugMode) {
    Logger.root.onRecord.listen((record) {
      print('''
        ${record.level.name} ${record.time}
        ${record.loggerName}: ${record.message}
        Exception: ${record.error}
        StackTrace:
        ${record.stackTrace}
      ''');
    });
  }
}