import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String email;
  final String name;
  final DateTime? lastLoginTime;

  const User({
    required this.email,
    required this.name,
    this.lastLoginTime,
  });

  bool get isEmpty => this == empty;

  static const empty = User(
    email: '',
    name: '',
    lastLoginTime: null,
  );

  @override
  List<Object?> get props => [email, name, lastLoginTime];

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'lastLoginTime': lastLoginTime?.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      lastLoginTime: map['lastLoginTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLoginTime'])
          : null,
    );
  }
}
