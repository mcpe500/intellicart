import 'package:intellicart/domain/entities/user.dart';
import 'package:intellicart/domain/repositories/user_repository.dart';
import 'package:intellicart/data/datasources/user_local_data_source.dart';
import 'package:intellicart/data/models/user_model.dart';

/// Implementation of the user repository interface.
///
/// This class provides the concrete implementation of the user repository
/// using the local data source.
class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  /// Creates a new user repository implementation.
  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<User> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCurrentUser();
      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> updateUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final updatedModel = await localDataSource.updateUser(userModel);
      return updatedModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      return await localDataSource.signOut();
    } catch (e) {
      rethrow;
    }
  }
}