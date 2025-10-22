// lib/models/user.dart
<<<<<<< HEAD
class User {
=======
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  final String id;
  final String email;
  final String name;
  final String role; // 'buyer' or 'seller'
<<<<<<< HEAD

  User({
=======
  final String? phoneNumber; // Phone number is optional

  const User({
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
    required this.id,
    required this.email,
    required this.name,
    required this.role,
<<<<<<< HEAD
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'buyer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
=======
    this.phoneNumber,
  });

  @override
  List<Object> get props => [id, email, name, role, phoneNumber ?? ''];

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
