import 'package:equatable/equatable.dart';

/*
Provides common sizes that should be used across the app for consistency.
They can be obtained using the extension on BuildContext by simply typing e.g. context.sizes.spaceM.
The sizes will be automatically scaled using the AppThemeData.scale factor that can be changed in the settings of the app.
*/
class Sizes extends Equatable {
  final double scale;

  double get spaceXS => 4 * scale;
  double get spaceS => 8 * scale;
  double get spaceM => 16 * scale;
  double get spaceL => 32 * scale;
  double get spaceXL => 48 * scale;

  const Sizes({
    this.scale = 1.0,
  });

  double scaled(double size) => scale * size;

  @override
  List<Object?> get props => [scale];
}
