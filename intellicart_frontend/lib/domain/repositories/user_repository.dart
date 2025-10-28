import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User> register(String email, String password, String name);
}