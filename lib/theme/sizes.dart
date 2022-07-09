import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [scale];
}
