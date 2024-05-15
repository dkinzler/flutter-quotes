import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> screenshotBytes) async {
      var path = 'screenshots/$name.png';
      final File image = File(path);
      // create parent folders if they don't already exist
      var parent = image.parent;
      if(!parent.existsSync()) {
        parent.createSync(recursive: true);
      }
      image.writeAsBytesSync(screenshotBytes);
      return true;
    },
  );
}
