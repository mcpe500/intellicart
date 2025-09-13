import 'package:sqflite/sqflite.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';
import 'package:intellicart/core/services/database_helper.dart';
import 'package:intellicart/data/models/user_model.dart';

/// Local data source for user operations.
///
/// This class provides methods for performing user-related operations
/// using the local SQLite database.
class UserLocalDataSource {
  final DatabaseHelper dbHelper;

  /// Creates a new user local data source.
  UserLocalDataSource({required this.dbHelper});

  /// Gets the current user from the local database.
  /// Returns the first user found or throws an exception if no user exists.
  Future<UserModel> getCurrentUser() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query('users');
      if (maps.isEmpty) {
        throw UserNotAuthenticatedException('No user found');
      }
      return UserModel.fromJson(maps.first);
    } on UserNotAuthenticatedException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get current user: ${e.toString()}');
    }
  }

  /// Updates the current user in the local database.
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final db = await dbHelper.db;
      
      // Check if user exists
      final List<Map<String, dynamic>> existingUsers = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [user.id],
      );
      
      if (existingUsers.isEmpty) {
        // Create new user
        final id = await db.insert('users', user.toJson());
        return user.copyWith(id: id);
      } else {
        // Update existing user
        await db.update(
          'users',
          user.toJson(),
          where: 'id = ?',
          whereArgs: [user.id],
        );
        return user;
      }
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update user: ${e.toString()}');
    }
  }

  /// Signs out the current user by clearing the users table.
  Future<void> signOut() async {
    try {
      final db = await dbHelper.db;
      await db.delete('users');
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to sign out: ${e.toString()}');
    }
  }
}