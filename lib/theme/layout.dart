import 'package:flutter/widgets.dart';

enum Layout {
  mobile,
  tablet,
  desktop;

  factory Layout.fromSize(Size size) {
    var shortest = size.shortestSide;
    if(shortest <= 400) {
      return mobile;
    } else if(shortest <= 800) {
      return tablet;
    } else {
      return desktop;
    }
  }
}