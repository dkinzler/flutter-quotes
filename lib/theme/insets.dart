import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class Insets extends Equatable {
  final double scale;

  EdgeInsetsGeometry get paddingXS => EdgeInsets.all(4.0 * scale);
  EdgeInsetsGeometry get paddingS => EdgeInsets.all(8.0 * scale);
  EdgeInsetsGeometry get paddingM => EdgeInsets.all(16.0 * scale);
  EdgeInsetsGeometry get paddingL => EdgeInsets.all(32.0 * scale);
  EdgeInsetsGeometry get paddingXL => EdgeInsets.all(48.0 * scale);

  const Insets({
    this.scale = 1.0,
  });

  EdgeInsetsGeometry symmetricScaled(
          {double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(
          horizontal: horizontal * scale, vertical: vertical * scale);

  EdgeInsetsGeometry symmetricAll(double value) =>
      EdgeInsets.all(value * scale);

  @override
  List<Object?> get props => [scale];
}
