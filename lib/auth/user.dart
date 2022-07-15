import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String email;

  const User({
    required this.email,
  });

  const User.empty() :
    email = '';

  @override
  List<Object?> get props => [email];
}