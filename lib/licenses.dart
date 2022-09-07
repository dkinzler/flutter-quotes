import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

//Add licenses to registry, so that they will be shown in the licenses
//page that can be reached via "Settings -> About this app" in the app.
void registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}
