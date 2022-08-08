import 'package:flutter/widgets.dart';

/*
Layout defines different device/screen types based on the screen size.

To extend this, we could e.g. take the screen orientation (portrait or landscape) into account.
*/
enum Layout {
  mobile,
  tablet,
  desktop;

  factory Layout.fromSize(Size size) {
    var shortest = size.shortestSide;
    if (shortest <= 400) {
      return mobile;
    } else if (shortest <= 800) {
      return tablet;
    } else {
      return desktop;
    }
  }
}
