import 'package:intellicart/domain/entities/user.dart';
import 'package:intellicart/domain/repositories/user_repository.dart';

/// Use case for updating the current user.
///
/// This use case encapsulates the business logic for updating the current user
/// in the repository.
class UpdateUser {
  final UserRepository repository;

  /// Creates a new UpdateUser use case.
  UpdateUser(this.repository);

  /// Executes the use case to update the current user.
  Future<User> call(User user) async {
    if (user.email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    if (user.name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    return await repository.updateUser(user);
  }
}