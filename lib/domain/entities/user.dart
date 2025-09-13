import 'package:equatable/equatable.dart';

/// A user of the application.
///
/// This class represents a user of the Intellicart application.
/// It contains information such as [email], [name], and [photoUrl].
///
/// Example:
/// ```dart
/// final user = User(
///   id: 1,
///   email: 'user@example.com',
///   name: 'John Doe',
///   photoUrl: 'https://example.com/avatar.jpg',
/// );
/// ```
class User extends Equatable {
  /// The unique identifier for this user.
  final int id;

  /// The email address of the user.
  final String email;

  /// The name of the user.
  final String name;

  /// URL to the user's profile photo.
  final String? photoUrl;

  /// Creates a new user.
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  /// Creates a copy of this user with the given fields replaced.
  User copyWith({
    int? id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Converts this user to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  /// Creates a user from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl];
}