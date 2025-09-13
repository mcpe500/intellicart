import 'package:intellicart/domain/repositories/user_repository.dart';

/// Use case for signing out the current user.
///
/// This use case encapsulates the business logic for signing out the current user
/// through the repository.
class SignOut {
  final UserRepository repository;

  /// Creates a new SignOut use case.
  SignOut(this.repository);

  /// Executes the use case to sign out the current user.
  Future<void> call() async {
    return await repository.signOut();
  }
}