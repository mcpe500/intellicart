import 'package:intellicart/domain/entities/user.dart';

/// Repository interface for user operations.
///
/// This interface defines the contract for user-related operations
/// that can be performed in the application.
abstract class UserRepository {
  /// Gets the current user.
  Future<User> getCurrentUser();

  /// Updates the current user.
  Future<User> updateUser(User user);

  /// Signs out the current user.
  Future<void> signOut();
}