import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? role;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, role, createdAt];

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'],
      createdAt: json['createdAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']) 
        : null,
    );
  }
}