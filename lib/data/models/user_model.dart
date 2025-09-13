import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/user.dart';

/// Data model for a user.
///
/// This class represents a user in the data layer and is used for
/// serializing and deserializing user data to and from the database.
class UserModel extends Equatable {
  /// The unique identifier for this user.
  final int id;

  /// The email address of the user.
  final String email;

  /// The name of the user.
  final String name;

  /// URL to the user's profile photo.
  final String? photoUrl;

  /// Creates a new user model.
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  /// Creates a user model from a user entity.
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      photoUrl: entity.photoUrl,
    );
  }

  /// Converts this user model to a user entity.
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
    );
  }

  /// Creates a copy of this user model with the given fields replaced.
  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Converts this user model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  /// Creates a user model from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl];
}