// lib/models/user.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role; // 'buyer' or 'seller'

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  @override
  List<Object> get props => [id, email, name, role];

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
