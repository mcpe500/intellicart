import 'package:intellicart/domain/entities/user.dart';
import 'package:intellicart/domain/repositories/user_repository.dart';

/// Use case for getting the current user.
///
/// This use case encapsulates the business logic for retrieving the current user
/// from the repository.
class GetCurrentUser {
  final UserRepository repository;

  /// Creates a new GetCurrentUser use case.
  GetCurrentUser(this.repository);

  /// Executes the use case to get the current user.
  Future<User> call() async {
    return await repository.getCurrentUser();
  }
}