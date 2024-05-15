import 'package:flutter/widgets.dart';

// Layout defines different device/screen types based on the screen size.
enum Layout {
  mobile,
  tablet,
  desktop;

  factory Layout.fromSize(Size size) {
    var shortest = size.shortestSide;
    if (shortest <= 450) {
      return mobile;
    } else if (shortest <= 800) {
      return tablet;
    } else {
      return desktop;
    }
  }
}
